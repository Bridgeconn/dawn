import { View, Text, StyleSheet } from 'react-native';

export default function MenuItem() {
  return (
    <View style={styles.container}>
      <Text>Menu</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
