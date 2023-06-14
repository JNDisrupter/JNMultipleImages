# JNMultipleImages

[![Build Status](https://travis-ci.org/JNDisrupter/JNMultipleImages.svg?branch=master)](https://travis-ci.org/JNDisrupter/JNMultipleImages)
[![Version](https://img.shields.io/cocoapods/v/JNMultipleImages.svg?style=flat)](http://cocoapods.org/pods/JNMultipleImages)
[![License](https://img.shields.io/cocoapods/l/JNMultipleImages.svg?style=flat)](http://cocoapods.org/pods/JNMultipleImages)
[![Platform](https://img.shields.io/cocoapods/p/JNMultipleImages.svg?style=flat)](http://cocoapods.org/pods/JNMultipleImages)

**JNMultipleImages** can be used to display multiple images in single view, it can be used in a newsfeed or posts. A single post can contain up to 4 displayed images, while showing a number with the remaining images if they are more than 4.

## Preview
<img src="https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages1.gif" width="280"/>  <img src="https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages2.gif" width="280"/>
<img src="https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages3.gif" width="280"/>
<img src="https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages4.gif" width="280"/>
<img src="https://github.com/JNDisrupter/JNMultipleImages/raw/master/Images/JNMultipleImages5.gif" width="280"/>

## Requirements

- iOS 11.0+ / macOS 12.3+
- Xcode 14.0+
- Swift 5.7+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate JNMultipleImages into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby

use_frameworks!

target '<Your Target Name>' do
pod 'JNMultipleImages'
end
```

Then, run the following command:

```bash
$ pod install
```
## Usage

#### To add JNMultipleImages in interface builder:

1. Put some UIView and change the class to "JNMultipleImages"

2. Add refrence for it in the view controller.

3. Change Attributes:

* You can change count label attributes by accessing it directly from the JNMultipleImages reference.
* delegate : this delegate confirm to JNMultipleImagesViewDelegate.

4. Call setup method:

Setup with JNImage array
```swift
setup(images: [JNImage], countLabelPosition: JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.lastItem, placeHolderImage: UIImage? = nil, itemsMargin : CGFloat = 2.0, style: JNMultipleImagesView.style = .collection, cornerRadius: CGFloat = 0)
```

Setup with array of any which might be Url String or UIImage
```swift
func setup(images: [Any], countLabelPosition: JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.lastItem, placeHolderImage: UIImage? = nil, itemsMargin: CGFloat = 2.0, style: JNMultipleImagesView.style = .collection, cornerRadius: CGFloat = 0)
```
##### parameters
* images : The images array to load.
* countLabelPosition : The position for the count label (Fill view or fill last item).
* placeHolderImage : The placeholder image to use for failed images.
* itemsMargin : The margin between items.
* style : The style of the view, it can be collection or a stack(horizental).
* cornerRadius : corner radius for images.

> The library will adjust the UIImageViews content mode automatically like the follows :
> * If the image dimensions is smaller than the image view dimensions then the content mode is aspectFill
> * If image width and height ratio less than the image view width and height ration then the content mode is aspectFill
> * If the image is landscape and the image height is less than the image view height then the content mode is topRight
> * Other than this it is aspectFit.

## Authors

Jayel Zaghmoutt & Mohammad Nabulsi

## License

JNMultipleImages is available under the MIT license. See the [LICENSE](https://github.com/JNDisrupter/JNMultipleImages/blob/master/LICENSE) file for more info.

