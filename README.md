# Documentation

## Step 1: Initialising SDK
```dart
if (await ApplovinPlugin.isInitialized() == false) {
await ApplovinPlugin.initialiseSDK(applovinSdkKey);
}
```

## Step 2: Setting up ad units
```dart
ApplovinPlugin.setApplovinAdUnits(
interstitialList: ["adUnit1", "adUnit2",....],
rewardedList: ["adUnit1", "adUnit2",....],
bannerTop: "bannerAdUnit",
bannerBottom: "bannerAdUnit",
);
```

## Step 3: Showing ads

#### i) Showing Video Ads (Not rewareded)
```dart
ApplovinPlugin.showVideoAd(rewarded: false);
```
#### ii) Showing Video Ads (Rewareded)
```dart
ApplovinPlugin.rewardFunction = (){
----reward code goes here-----
};
ApplovinPlugin.showVideoAd(rewarded: true);
```
#### iii) Show Banner Ads
```dart
ApplovinPlugin.showBannerTop();
ApplovinPlugin.showBannerBottom();
```
#### iv) Hiding Banner Ads
```dart
ApplovinPlugin.hideBannerTop();
ApplovinPlugin.hideBannerBottom();
```