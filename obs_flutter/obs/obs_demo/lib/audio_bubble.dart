import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioBubble extends StatelessWidget {
  final String? recordedFilePath;
  final RecorderController? recorderController;
  final PlayerController? playerController;
  final int currentPositionInSeconds;

  const AudioBubble({
    Key? key,
    this.recordedFilePath,
    this.recorderController,
    this.playerController,
    required this.currentPositionInSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 92, 91, 95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recordedFilePath != null && recorderController != null)
            Column(
              children: [
                AudioWaveforms(
                  enableGesture: true,
                  size: Size(MediaQuery.of(context).size.width / 1.08, 80),
                  recorderController: recorderController!,
                  waveStyle: WaveStyle(
                      waveColor: Colors.white,
                      extendWaveform: true,
                      showDurationLabel: true),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color(0xFF1E1B26),
                  ),
                  padding: const EdgeInsets.only(left: 18),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                ),
                SizedBox(height: 8),
                // Text(
                //   _formatDuration(Duration(seconds: currentPositionInSeconds)),
                //   style: TextStyle(color: Colors.white),
                // ),
              ],
            ),
          if (recordedFilePath != null && playerController != null)
            Column(
              children: [
                AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width, 80),
                  enableSeekGesture: true,
                  waveformType: WaveformType.long,
                  playerController: playerController!,
                  playerWaveStyle: const PlayerWaveStyle(
                    scaleFactor: 0.8,
                    fixedWaveColor: Colors.white54,
                    liveWaveColor: Colors.blueAccent,
                    // spacing: 6,
                    waveCap: StrokeCap.butt,
                  ),
                ),
                SizedBox(height: 8),
                // Text(
                //   _formatDuration(Duration(seconds: currentPositionInSeconds)),
                //   style: TextStyle(color: Colors.white),
                // ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
