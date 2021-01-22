declare module 'react-native-misnap' {
  export interface MiSnapConfig {
    captureType: 'idFront' | 'idBack' | 'face' ;
    autocapture: boolean;
    livenessLicenseKey: string;
  }

  export interface MiSnapResult {
    base64encodedImage: string;
    metadata?: Record<string, string>;
  }

  const defaultConfig: MiSnapConfig = {
    captureType: 'idFront',
    autocapture: true,
  };

  export default class MiSnapManager {
    static greet(): Promise<string>;

    static capture(config: MiSnapConfig = defaultConfig): Promise<MiSnapResult>;
  }
}
