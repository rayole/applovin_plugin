import 'package:applovin_max/applovin_max.dart';
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:flutter/foundation.dart';

enum AdPosition {
  topCenter,
  topRight,
  centered,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum _VideoType {
  rewarded,
  interstitial
}

class ApplovinPlugin {
  static Function rewardFunction = () {};
  static bool _adUnitSetUpComplete = false;
  static List<String> _interstitialUnitList = [];
  static List<String> _rewardedUnitList = [];
  static List<String> _mrecUnitList = [];
  static String _bannerBottom = "";
  static String _bannerTop = "";
  static _VideoType _videoAdType = _VideoType.rewarded;
  static int _iIndex = 0;
  static int _rIndex = 0;
  static int _mRecIndex = 0;
  static final Map<String, bool> _isMRecLoaded = {};

  static Future<Map?> initialiseSDK(String sdkKey) async {
    return await AppLovinMAX.initialize(sdkKey);
  }

  static Future<bool?> isInitialized() async {
    return await AppLovinMAX.isInitialized();
  }

  static void _setInterstitialListener() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        if (kDebugMode) {
          print('Interstitial ad loaded from ' + ad.networkName);
        }
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        if (kDebugMode) {
          print('Interstitial ad failed to load with code ' +
              error.code.toString());
        }
      },
      onAdDisplayedCallback: (ad) {
        if (kDebugMode) {
          print('Interstitial ad displayed SUCCESS');
        }
      },
      onAdDisplayFailedCallback: (ad, error) async{
        await Future.delayed(const Duration(seconds: 1));
        if (kDebugMode) {
          print('Interstitial ad displayed FAILED');
          print('Trying to Load Ad : Interstitial, index: '+ _iIndex.toString());
        }
        AppLovinMAX.loadInterstitial(_interstitialUnitList[_iIndex]);
        _changeVideoAdShowingUnit();
        if (kDebugMode) {
          print('New Index for Interstitial: '+ _iIndex.toString());
        }
      },
      onAdClickedCallback: (ad) {
        if (kDebugMode) {
          print('Interstitial ad Clicked');
        }
      },
      onAdHiddenCallback: (ad) async{
        if (await CheckVpnConnection.isVpnActive() == false) {
          rewardFunction();
        }
        rewardFunction = () {};
        if (kDebugMode) {
          print('Interstitial ad hidden');
          print('Trying to Load Ad : Interstitial, index: '+ _iIndex.toString());
        }
        AppLovinMAX.loadInterstitial(_interstitialUnitList[_iIndex]);
        _changeVideoAdShowingUnit();
        if (kDebugMode) {
          print('New Index for Interstitial: '+ _iIndex.toString());
        }
      },
    ));
  }

  static void _setRewardedAdListener() {
    AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
            onAdLoadedCallback: (ad) {
              // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
              if (kDebugMode) {
                print('Rewarded ad loaded from ' + ad.networkName);
              }
            },
            onAdLoadFailedCallback: (adUnitId, error) {
              if (kDebugMode) {
                print('Rewarded ad failed to load with code ' +
                    error.code.toString());
              }
            },
            onAdDisplayedCallback: (ad) {
              if (kDebugMode) {
                print('Rewarded ad displayed : SUCCESS');
              }
            },
            onAdDisplayFailedCallback: (ad, error) {
              if (kDebugMode) {
                print('Rewarded ad displayed : FAILURE');
                print('Trying to Load Ad : Rewarded, index: '+ _rIndex.toString());
              }
              AppLovinMAX.loadRewardedAd(_rewardedUnitList[_rIndex]);
              _changeVideoAdShowingUnit();
              if (kDebugMode) {
                print('New Index for Rewarded: '+ _rIndex.toString());
              }
            },
            onAdClickedCallback: (ad) {
              if (kDebugMode) {
                print('Rewarded ad CLICKED');
              }
            },
            onAdHiddenCallback: (ad) async{
              await Future.delayed(const Duration(seconds: 1));
              if (kDebugMode) {
                print('Rewarded ad HIDDEN');
                print('Trying to Load Ad : Rewarded, index: '+ _rIndex.toString());
              }
              AppLovinMAX.loadRewardedAd(_rewardedUnitList[_rIndex]);
              _changeVideoAdShowingUnit();
              if (kDebugMode) {
                print('New Index for Rewarded: '+ _rIndex.toString());
              }
            },
            onAdReceivedRewardCallback: (ad, reward) async{
              if (kDebugMode) {
                print('Rewarded ad REWARDED CALLBACK');
              }
              if (await CheckVpnConnection.isVpnActive() == false) {
                rewardFunction();
              }
              rewardFunction = () {};
            }));
  }

  static void _setBanneristener() {
    AppLovinMAX.setBannerListener(
        AdViewAdListener(
            onAdLoadedCallback: (ad) {
              if (kDebugMode) {
                print('Banner ad loaded from ' + ad.networkName);
              }
            },
            onAdLoadFailedCallback: (adUnitId, error) {
              if (kDebugMode) {
                print('Banner ad failed to load with code ' +
                    error.code.toString());
              }
              _createBannerAd(adUnitId: adUnitId, bannerPosition: adUnitId == _bannerBottom ? AdPosition.bottomCenter : AdPosition.topCenter);
            },
            onAdCollapsedCallback: (ad) {
              if (kDebugMode) {
                print('Banner Ad Collapsed');
              }
            },
            onAdExpandedCallback: (ad) {
              if (kDebugMode) {
                print('Banner Ad Expanded');
              }
            },
            onAdClickedCallback: (ad) {
              if (kDebugMode) {
                print('Baner Ad Clicked');
              }
            },
        )
    );
  }

  static void _setMRecListener() {
    AppLovinMAX.setMRecListener(
        AdViewAdListener(
          onAdLoadedCallback: (ad) {
            _isMRecLoaded[ad.adUnitId] = true;
            if (kDebugMode) {
              print('MREC ad loaded from ' + ad.networkName);
            }
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            if (kDebugMode) {
              print('MREC ad failed to load with code ' +
                  error.code.toString());
            }
            _createMRecAd(adUnitId);
          },
          onAdCollapsedCallback: (ad) {
            if (kDebugMode) {
              print('MREC Ad Collapsed');
            }
          },
          onAdExpandedCallback: (ad) {
            if (kDebugMode) {
              print('MREC Ad Expanded');
            }
          },
          onAdClickedCallback: (ad) {
            if (kDebugMode) {
              print('MREC Ad Clicked');
            }
          },
        )
    );
  }

  static void setApplovinAdUnits({required List<String> interstitialList, required List<String> rewardedList, required List<String> mrecList, required String bannerBottom, required String bannerTop}) {
    _adUnitSetUpComplete = true;
    _setInterstitialListener();
    _setRewardedAdListener();
    _setBanneristener();
    _setMRecListener();
    _interstitialUnitList = interstitialList;
    _rewardedUnitList = rewardedList;
    _mrecUnitList = mrecList;
    _bannerBottom = bannerBottom;
    _bannerTop = bannerTop;
    for (var adUnit in _interstitialUnitList) {
      AppLovinMAX.loadInterstitial(adUnit);
    }
    for (var adUnit in _rewardedUnitList) {
      AppLovinMAX.loadRewardedAd(adUnit);
    }
    for (var adUnit in _mrecUnitList) {
      _isMRecLoaded[adUnit] = false;
      _createMRecAd(adUnit);
    }
    _createBannerAd(adUnitId: _bannerTop, bannerPosition: AdPosition.topCenter);
    _createBannerAd(adUnitId: _bannerBottom, bannerPosition: AdPosition.bottomCenter);
  }

  static void showVideoAd({required bool rewarded}) async{
    if (rewarded == false) {
      rewardFunction = () {};
    } else {
      if (rewardFunction == (){}){
        throw Exception("UndefinedRewardFunction");
      }
    }
    if (!_adUnitSetUpComplete) {
      throw Exception("AdUnitListMissingException");
    }
    int i = 0;
    while (i < _rewardedUnitList.length + _interstitialUnitList.length) {
      if (kDebugMode) {
        print("Trying to Show -- " + _videoAdType.toString() +" index: "+ (_videoAdType == _VideoType.rewarded ? _rIndex : _iIndex).toString());
      }
      i++;
      if (_videoAdType == _VideoType.rewarded) {
        if ((await AppLovinMAX.isRewardedAdReady(_rewardedUnitList[_rIndex])) == true) {
          AppLovinMAX.showRewardedAd(_rewardedUnitList[_rIndex]);
          break;
        } else {
          if (kDebugMode) {
            print('Rewarded ad is not loaded yet!!!');
            print('Trying to Load Ad : Rewarded, index: '+ _rIndex.toString());
          }
          AppLovinMAX.loadRewardedAd(_rewardedUnitList[_rIndex]);
          _changeVideoAdShowingUnit();
          if (kDebugMode) {
            print('New Index for Rewarded: '+ _rIndex.toString());
          }
        }
      } else {
        if ((await AppLovinMAX.isInterstitialReady(_interstitialUnitList[_iIndex])) == true) {
          AppLovinMAX.showInterstitial(_interstitialUnitList[_iIndex]);
          break;
        } else {
          if (kDebugMode) {
            print('Interstitial ad is not loaded yet!!!');
            print('Trying to Load Ad : Interstitial, index: '+ _iIndex.toString());
          }
          AppLovinMAX.loadInterstitial(_interstitialUnitList[_iIndex]);
          _changeVideoAdShowingUnit();
          if (kDebugMode) {
            print('New Index for Interstitial: '+ _iIndex.toString());
          }
        }
      }
    }
  }

  static void _changeVideoAdShowingUnit() {
    if (_videoAdType == _VideoType.rewarded) {
      _videoAdType = _VideoType.interstitial;
      if (_rIndex + 1 < _rewardedUnitList.length) {
        _rIndex++;
      } else {
        _rIndex = 0;
      }
    } else {
      _videoAdType = _VideoType.rewarded;
      if (_iIndex + 1 < _interstitialUnitList.length) {
        _iIndex++;
      } else {
        _iIndex = 0;
      }
    }
  }

  static void _createBannerAd({required String adUnitId, required AdPosition bannerPosition}) {
    AdViewPosition viewPosition = AdViewPosition.bottomCenter;
    switch (bannerPosition) {
      case AdPosition.bottomCenter:
        viewPosition = AdViewPosition.bottomCenter;
        break;
      case AdPosition.topCenter:
        viewPosition = AdViewPosition.topCenter;
        break;
      case AdPosition.topRight:
        viewPosition = AdViewPosition.topRight;
        break;
      case AdPosition.centered:
        viewPosition = AdViewPosition.centered;
        break;
      case AdPosition.centerLeft:
        viewPosition = AdViewPosition.centerLeft;
        break;
      case AdPosition.centerRight:
        viewPosition = AdViewPosition.centerRight;
        break;
      case AdPosition.bottomLeft:
        viewPosition = AdViewPosition.bottomLeft;
        break;
      case AdPosition.bottomRight:
        viewPosition = AdViewPosition.bottomRight;
        break;
    }
    AppLovinMAX.createBanner(adUnitId, viewPosition);
  }

  static void showBannerTop() {
    AppLovinMAX.showBanner(_bannerTop);
  }

  static void showBannerBottom() {
    AppLovinMAX.showBanner(_bannerBottom);
  }

  static void hideBannerTop() {
    AppLovinMAX.hideBanner(_bannerTop);
  }

  static void hideBannerBottom() {
    AppLovinMAX.hideBanner(_bannerBottom);
  }

  static void _createMRecAd(String adUnitId) {
    AdViewPosition viewPosition = AdViewPosition.centered;
    AppLovinMAX.createMRec(adUnitId, viewPosition);
  }

  static bool isMRecAdReady() {
    if (_isMRecLoaded.containsKey(_mrecUnitList[_mRecIndex]) && _isMRecLoaded[_mrecUnitList[_mRecIndex]]!) {
      return true;
    }
    return false;
  }

  static void showMRecAd() {
    if (kDebugMode) {
      print("Trying to show MREC ad for index: " + _mRecIndex.toString());
    }
    AppLovinMAX.showMRec(_mrecUnitList[_mRecIndex]);
  }

  static void hideMRecAd() {
    AppLovinMAX.hideMRec(_mrecUnitList[_mRecIndex]);
    _changeMRecIndex();
  }

  static void _changeMRecIndex() {
    if (_mRecIndex + 1 < _rewardedUnitList.length) {
      _mRecIndex++;
    } else {
      _mRecIndex = 0;
    }
  }
}