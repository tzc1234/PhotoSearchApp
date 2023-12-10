# PhotoSearchApp
## Practice the learnings from iOS Lead Essentials, episode 2. 
**Note that you will need a flickr API key to run this app.
All snapshot tests in this project are run on iPhone 15(iOS 17.0.1) simulator.**

## Screenshot
<img src="https://github.com/tzc1234/PhotoSearchApp/blob/main/Screenshots/preview.png" alt="preview" width="256" height="554"/>

## Frameworks
1. Combine
2. URLSession for [flickr API](https://www.flickr.com/services/api/)
3. UIKit
4. XCTest
5. NSCache for in memory image caching

## Techniques
1. Follow SOLID principles
2. Adopt TDD
3. Use of dependency injection
4. Refactor from MVC to MVP, safeguard by tests
5. "Glue" the components by Combine in the composition root

## Photo Search Feature Specs

### Story: User requests to search photos

### Narrative #1

```
As an online user
I want the app automatically load photos
So I can enjoy those photos
```

#### Scenarios (Acceptance criteria)

```
Given the user has connectivity
When the user request to see the photos
Then the app should display the photos from remote
```

### Narrative #2

```
As an online user
I want to search the photos by keywords from the app
So I can enjoy photos of the category by the keyword I entered
```

#### Scenarios (Acceptance criteria)

```
Given the user has connectivity
When the user search photos by entering keywords
Then the app should display photos of specific category by the entered keyword
```

### Narrative #3

```
As an offline user
I want the app to show an message to tell me I am offline
So I know what's going on
```

### Scenarios (Acceptance criteria)

```
Given the user has no connectivity
When the user requests photos or search photos
Then the app should display an error message
```
---