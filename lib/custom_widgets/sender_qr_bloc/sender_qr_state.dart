abstract class SenderQrState {
  const SenderQrState();
}

class Initial extends SenderQrState {
  const Initial();
}

class ConnectionWaiting extends SenderQrState {
  final String verificationString;
  final String ip;
  final int port;
  final Duration currentDuration;
  const ConnectionWaiting(this.ip, this.port, this.verificationString,
      {this.currentDuration = Duration.zero});
}
