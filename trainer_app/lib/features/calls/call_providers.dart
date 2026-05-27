import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

const _kTokenServerUrl = 'http://192.168.29.189:3001';

enum CallPhase { idle, loading, preJoin, joining, inCall, postCall, error }

class CallState {
  const CallState({
    this.phase = CallPhase.idle,
    this.localVideoTrack,
    this.remotePeers = const [],
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.token,
    this.roomMeta,
    this.error,
    this.startedAt,
    this.endedAt,
    this.sessionLogId,
  });

  final CallPhase phase;
  final HMSVideoTrack? localVideoTrack;
  final List<HMSPeer> remotePeers;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final String? token;
  final RoomMeta? roomMeta;
  final String? error;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? sessionLogId;

  CallState copyWith({
    CallPhase? phase,
    HMSVideoTrack? localVideoTrack,
    List<HMSPeer>? remotePeers,
    bool? isAudioMuted,
    bool? isVideoMuted,
    String? token,
    RoomMeta? roomMeta,
    String? error,
    DateTime? startedAt,
    DateTime? endedAt,
    String? sessionLogId,
  }) => CallState(
    phase: phase ?? this.phase,
    localVideoTrack: localVideoTrack ?? this.localVideoTrack,
    remotePeers: remotePeers ?? this.remotePeers,
    isAudioMuted: isAudioMuted ?? this.isAudioMuted,
    isVideoMuted: isVideoMuted ?? this.isVideoMuted,
    token: token ?? this.token,
    roomMeta: roomMeta ?? this.roomMeta,
    error: error ?? this.error,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    sessionLogId: sessionLogId ?? this.sessionLogId,
  );
}

class CallNotifier extends StateNotifier<CallState>
    implements HMSUpdateListener, HMSActionResultListener {
  CallNotifier(this._ref) : super(const CallState());

  final Ref _ref;
  late HMSSDK _hms;
  String? _currentRequestId;

  Future<void> initCall(String requestId) async {
    state = state.copyWith(phase: CallPhase.loading);
    try {
      final callService = _ref.read(callServiceProvider);
      final roomMeta = await callService.getRoomMeta(requestId);
      if (roomMeta == null) throw Exception('Room not found for request $requestId');

      final user = _ref.read(currentUserProvider)!;
      final role = roomMeta.hmsRoleTrainer;

      final resp = await http.get(Uri.parse(
          '$_kTokenServerUrl/token?userId=${user.id}&role=$role&roomId=${roomMeta.hmsRoomId}'));
      if (resp.statusCode != 200) throw Exception('Token server error: ${resp.body}');
      final token = jsonDecode(resp.body)['token'] as String;

      _currentRequestId = requestId;
      state = state.copyWith(phase: CallPhase.preJoin, token: token, roomMeta: roomMeta);
      DevLogger.instance.log('[RTC]', 'Trainer pre-join ready for room ${roomMeta.hmsRoomId}');
    } catch (e) {
      state = state.copyWith(phase: CallPhase.error, error: e.toString());
      DevLogger.instance.error('[RTC]', 'initCall failed: $e');
    }
  }

  Future<void> joinCall() async {
    if (state.token == null) return;
    state = state.copyWith(phase: CallPhase.joining);
    try {
      final user = _ref.read(currentUserProvider)!;
      _hms = HMSSDK();
      await _hms.build();
      _hms.addUpdateListener(listener: this);
      await _hms.join(config: HMSConfig(authToken: state.token!, userName: user.name));
      state = state.copyWith(phase: CallPhase.inCall, startedAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(phase: CallPhase.error, error: e.toString());
    }
  }

  Future<void> toggleAudio() async { await _hms.toggleMicMuteState(); state = state.copyWith(isAudioMuted: !state.isAudioMuted); }
  Future<void> toggleVideo() async { await _hms.toggleCameraMuteState(); state = state.copyWith(isVideoMuted: !state.isVideoMuted); }
  Future<void> switchCamera() async { await _hms.switchCamera(); }

  Future<void> endCall() async {
    state = state.copyWith(endedAt: DateTime.now());
    await _hms.leave(hmsActionResultListener: this);
  }

  Future<void> _writeSessionLog() async {
    if (_currentRequestId == null || state.startedAt == null) return;
    final endedAt = state.endedAt ?? DateTime.now();
    final req = await _ref.read(callServiceProvider).getRequest(_currentRequestId!);
    if (req == null) return;
    final logId = const Uuid().v4();
    final log = SessionLog(
      id: logId,
      memberId: req.memberId,
      trainerId: req.trainerId,
      startedAt: state.startedAt!,
      endedAt: endedAt,
      durationSec: endedAt.difference(state.startedAt!).inSeconds,
    );
    await _ref.read(logServiceProvider).saveLog(log);
    state = state.copyWith(sessionLogId: logId);
    DevLogger.instance.log('[RTC]', 'Trainer session log written: ${log.durationSec}s');
  }

  @override void onJoin({required HMSRoom room}) { DevLogger.instance.log('[RTC]', 'Trainer joined ${room.id}'); }
  @override void onPeerListUpdate({required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {
    final updated = List<HMSPeer>.from(state.remotePeers);
    for (final p in removedPeers) { updated.removeWhere((e) => e.peerId == p.peerId); }
    for (final p in addedPeers) { if (!p.isLocal) updated.add(p); }
    state = state.copyWith(remotePeers: updated);
  }
  @override void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerJoined && !peer.isLocal) {
      state = state.copyWith(remotePeers: [...state.remotePeers, peer]);
    } else if (update == HMSPeerUpdate.peerLeft) {
      state = state.copyWith(remotePeers: state.remotePeers.where((p) => p.peerId != peer.peerId).toList());
    }
  }
  @override void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}
  @override void onTrackUpdate({required HMSTrack track, required HMSTrackUpdate trackUpdate, required HMSPeer peer}) {
    if (track is HMSVideoTrack && peer.isLocal && trackUpdate == HMSTrackUpdate.trackAdded) {
      state = state.copyWith(localVideoTrack: track);
    }
  }
  @override void onHMSError({required HMSException error}) { DevLogger.instance.error('[RTC]', error.message ?? ''); state = state.copyWith(error: error.message); }
  @override void onMessage({required HMSMessage message}) {}
  @override void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}
  @override void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
  @override void onReconnecting() { state = state.copyWith(phase: CallPhase.joining); }
  @override void onReconnected() { state = state.copyWith(phase: CallPhase.inCall); }
  @override void onChangeTrackStateRequest({required HMSTrackChangeRequest hmsTrackChangeRequest}) {}
  @override void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    state = state.copyWith(phase: CallPhase.postCall, endedAt: DateTime.now());
    _writeSessionLog();
  }
  @override void onAudioDeviceChanged({HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {}
  @override void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}
  @override void onSuccess({HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown, Map<String, dynamic>? arguments}) {
    if (methodType == HMSActionResultListenerMethod.leave) {
      state = state.copyWith(phase: CallPhase.postCall);
      _writeSessionLog();
    }
  }
  @override void onException({HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown, Map<String, dynamic>? arguments, required HMSException hmsException}) {}

  @override
  void dispose() {
    try { _hms.removeUpdateListener(listener: this); } catch (_) {}
    super.dispose();
  }
}

final callNotifierProvider = StateNotifierProvider<CallNotifier, CallState>((ref) => CallNotifier(ref));
