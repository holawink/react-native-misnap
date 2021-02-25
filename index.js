import { NativeModules } from 'react-native';

const { RNMisnap } = NativeModules;

export default {
  greet():Promise<string> {
    return RNMisnap.greet();
  },

  capture(config) {
    return RNMisnap.capture(config);
  },
};
