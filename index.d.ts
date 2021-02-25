declare module 'react-native-misnap' {
  export interface MiSnapConfig {
    captureType: 'idFront' | 'idBack' | 'face';
    autocapture: boolean;
    livenessLicenseKey: string;
    glare: number;
    contrast: number;
    imageQuality: number;
  }

  export interface MiSnapResult {
    base64encodedImage: string;
    metadata?: Record<string, string>;
  }

  const defaultConfig: MiSnapConfig = {
    captureType: 'idFront',
    autocapture: true,
    livenessLicenseKey: '',
    glare: 200,
    contrast: 180,
    imageQuality: 95,
  };

  export default class MiSnapManager {
    static greet(): Promise<string>;

    static capture(config: MiSnapConfig = defaultConfig): Promise<MiSnapResult>;
  }
}
