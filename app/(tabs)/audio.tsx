import React from 'react'
import { View, Text,Button,TouchableOpacity, StyleSheet } from 'react-native';
import { Audio } from 'expo-av';
import Icon from 'react-native-vector-icons/FontAwesome';

export default function AudioPlayer() {
  const [recording,setRecording]=React.useState()
  const [recordings,setRecordings]=React.useState([])
  
  async function startRecording() {
    try {
      const perm = await Audio.requestPermissionsAsync();
      if (perm.status === "granted") {
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: true,
          playsInSilentModeIOS: true
        });
        const { recording } = await Audio.Recording.createAsync(Audio.RECORDING_OPTIONS_PRESET_HIGH_QUALITY);
        setRecording(recording);
      }
    } catch (err) {}
  }

  async function stopRecording() {
    setRecording(undefined);

    await recording.stopAndUnloadAsync();
    let allRecordings = [...recordings];
    const { sound, status } = await recording.createNewLoadedSoundAsync();
    allRecordings.push({
      sound: sound,
      duration: getDurationFormatted(status.durationMillis),
      file: recording.getURI()
    });

    setRecordings(allRecordings);
  }

  function getDurationFormatted(milliseconds) {
    const minutes = milliseconds / 1000 / 60;
    const seconds = Math.round((minutes - Math.floor(minutes)) * 60);
    return seconds < 10 ? `${Math.floor(minutes)}:0${seconds}` : `${Math.floor(minutes)}:${seconds}`
  }

  function getRecordingLines() {
    return recordings.map((recordingLine, index) => {
      return (
        <View key={index} style={styles.row}>
          <Text style={styles.fill}>
            Recording #{index + 1} | {recordingLine.duration}
          </Text>
          <Button onPress={() => recordingLine.sound.replayAsync()} title="Play"></Button>
        </View>
      );
    });
  }

  function clearRecordings() {
    setRecordings([])
  }

  return (
    <View style={styles.container}>
      {/* <Button title={recording ? 'Stop Recording' : 'Start Recording\n\n\n'}  onPress={recording ? stopRecording : startRecording} />
      {recordings?getRecordingLines():""}
      <Button title={recordings.length > 0 ? '\n\n\nClear Recordings' : ''} onPress={clearRecordings} /> */}
    <TouchableOpacity onPress={recording ? stopRecording : startRecording} style={styles.appButtonContainer}>
      <Text style={styles.appButtonText}>{recording ?
       <Icon
      name="square"
      size={45}
      color="red"
    /> : <Icon
      name="circle"
      size={45}
      color="red"
    />}</Text>
    <Text style={styles.appButtonText}>{recording ?
       'Stop Recording':'Start Recording'}</Text>
    </TouchableOpacity>
    {recordings.length > 0?<TouchableOpacity onPress={clearRecordings} style={styles.appButtonContainer}>
    <Text style={styles.appButtonText}>  {recordings.length > 0 ? 'Clear Recordings' : ''}</Text>
    </TouchableOpacity>:""}
    {recordings?getRecordingLines():""}
    </View>
  );
};



const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  appButtonContainer: {
    elevation: 8,
    backgroundColor: "#009688",
    borderRadius: 10,
    paddingVertical: 10,
    paddingHorizontal: 12
  },
  appButtonText:{
    fontSize: 18,
    color: "#fff",
    fontWeight: "bold",
    alignSelf: "center",
    textTransform: "uppercase"
  }
});
