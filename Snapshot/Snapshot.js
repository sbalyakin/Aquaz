#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
captureLocalizedScreenshot("1-Drinks")

target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[0].cells()[0].tap();
captureLocalizedScreenshot("4-Intake")

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().tabBar().buttons()[1].tap();
target.frontMostApp().mainWindow().scrollViews()[0].buttons()["IconLeftActive"].tap();
captureLocalizedScreenshot("5-Statistics")

target.frontMostApp().tabBar().buttons()[2].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot("2-WaterGoal")

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[3].tap();
captureLocalizedScreenshot("3-Notifications")
