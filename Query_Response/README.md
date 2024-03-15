# Gender Checker Application README

## Overview

This Gender Checker application, built using SwiftUI, offers users a text-based adventure where they can input a name and receive gender-related information using a free API. The app focuses on two core functionalities: caching input responses to prevent multiple API requests and saving screenshots of the resulting web page for future reference.

Key Features:
Gender API Integration:
Users input a name, triggering a request to a free API for gender-related information.
The app caches the API response for each input, reducing the need for repetitive API calls.

Input Response Cache Management:
Responses to user inputs are cached in CoreData for 10 minutes.
If a user enters the same name again within this timeframe, the cached response is used instead of re-fetching from the API.

Screenshot Saving and Management:
The app captures and saves screenshots of the web page displaying the gender-related information.
These screenshots are stored locally on the device and are automatically deleted after 30 minutes to manage storage efficiently.

## Build and Run Instructions

1. Clone the repository to your local machine.
2. Ensure you have Xcode installed.
3. Right click on .xcodeproj to open the project.
4. Click on Run button to run the application.

## Architecture

In this I have followed the MVVM Architecture which includes the `Model`, `ViewModels`, `Views` :

- `Model`: This folder includes the file name as `GenderModel.swift` which basically represents the expected data from Api response.
- `ViewModels`: This folder includes the `GenderViewModel.swift` in which one method is written named as `fetchGender` which is basically called from view after entering the name. This method is called Async to get data and have handled the edge cases by exception handling using the try catch. This method then called the GenderNetworkService class method to make the APi call. After the successfully executed that method returns the gender by decoding the json data into model name as `GenderModel` and also saved the response in CoreData in entity name as `CachedResponseEntity` having attributes timestamp, input and response then webview is shown as navigation view which shows the formatted output in some nice look. Here comes up the functionality to capture the screenshot of the webview screen after the 1.5 second and by doing some animation to produce screenshot feelings to save data in png into the document directory by calling the method named as `saveScreenshotToDocumentDirectory` then here needs to save the file name with time stamp into the CoreData by called the method of persistenceController named as `saveScreenshot`. Now, when user will get back to Gender Checker screen and will enter the same input again now when again `fetchGender` will be called but it will first check the cache by called method written in persistenceController whether response against this input is already cached or not. if cached then will return the cached response otherwise will need to hit api and save the result for 10 mintues. (This logic for 10 mints of input response cache and screenshot cache is handled on App Launch will discuss later).
- `Views`: This folder holds three views named as:
`GenderCheckerView.swift` which is the main view which holds the logic to build view have navigation bar title, input field and button. Alert and progress view that will be shown on condition based.
`ScreenShotView.swift` holds the logic to take screenshot after the 1.5 seconds of webview shown. That screenshot will be saved into document directory by calling the method of saveScreenshotToDocumentDirectory in background thread to avoid from main thread blockage.
- `Important`: The core logic is mananged on launch of app which is to start the timer and called the methods after the time of 1 minute to check if screenshots have timestamp 30 minutes old to delete that from document directory and from CoreData. Also to delete the input cached response having timestamp more than 10 minutes.
    This functionality is being handled on background thread to keep app's performance good.
`CacheModel` is the model file in which schemas are defined for screenshot cache (CachedResponseEntity) and input result cache (ScreenshotsEntity).

- `README.md`: This file providing instructions, architecture overview, and development details.

## Development Stack

- **SwiftUI**: In this Apple's decelarative framework named as SwiftUI is used for making the UI and swift language is used to implement other functionality. Also for local persistane, CoreData is used developed by Apple's Team which basically utilizes SQLite as its default persistent store. However, it's important to note that Core Data abstracts the underlying storage mechanism, allowing developers to work with object graphs in their applications without directly interacting with the SQLite database. Core Data provides a higher-level API for managing data objects and their relationships, handling tasks such as data fetching, persistence, and relationship management. Under the hood, Core Data manages the SQLite database transparently, enabling developers to focus on their application's data model and business logic.

## Feedback and Contributions

Feedback and contributions are welcome! If you encounter any issues, have suggestions for improvements, or would like to contribute additional scenarios or features, please open an issue or submit a pull request on GitHub.
