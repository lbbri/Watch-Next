

# Watch Next

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Watch Next allows users to keep track of what movies and TV Shows they have watched on different streaming platforms while also returning personalized suggestions. 

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Entertainment 
- **Mobile:** Mobile focused design. 
- **Story:** The app allows users to easily log and rate anything they have watched to provide a personalized suggestions list. Users can also see what friends have logged in order to acquire suggestions.
- **Market:** The app's potential user base consists of cinema watchers who may not be satisfied with the suggestions of individual streaming service suggestions. The app is targeted towards users who use multiple streaming services such as Netflix and Hulu.
- **Habit:** The Average User would use this app whenever they finish a TV show or movie. Multiple times a week.
- **Scope:** The app may have to interact with multiple API's in order to have access to a wholesome list of movies/TV shows. The more complex side to the project is creating a solid suggestions list. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can create new Watch Next profile.
* User can use camera to set profile picture.
* User can log in/out of their Watch Next profile.
* User can search for movie/TV show Title and get correct results.
* User can mark a movie/TV show as watched.
* User can mark a movie/TV show as watch next.
* User can rate thier watched movies/TV shows on a scale of 1 to 10.
* User can mark watched movie/TV show as 'would/wouldn't watch again.'
* User can see suggested movies/TV shows based off of a specific watched movie/TV show.
* User can view their Watched/ Watch Next Lists.
* User can view another user's watched list. 

**Optional Nice-to-have Stories**

* User can view a more curated suggestions list based off of their entire watched list and its internal ratings.
* User can get an automatic comparison of watched/ watch next lists with other users. e.g 'You and User2 have both watched The Office'
* The app will ask user 'Have you watched [this suggested movie] based on [this movie on your watched list]?'
* User can suggest movie/TV show to another specific user.
* User can mark what streaming platform they watched the movie/TV show on (if applicable).
* Users can talk about a specific movie/TV show in a spoilers section.
* User can set thier 'favorite movie'. 

### 2. Screen Archetypes

* Registration Screen 
   * User can create new Watch Next profile
   * User can use camera to set profile picture.
* Login Screen
   * User can login to their Watch Next Profile
* Search Screen 
   * User can search for movie/TV show Title and get correct results.
* Movie/TV Screen
   * User can mark a movie/TV show as watched.
    * User can mark a movie/TV show as watch next.
    * User can rate thier watched movies/TV shows on a scale of 1 to 10.
    * User can mark watched movie/TV show as 'would/wouldn't watch again.'
    * User can see suggested movies/TV shows based off of a specific watched movie/TV show.
* User Proile Screen
   * User can view their Watched/ Watch Next Lists.

  

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home [maybe like a Tinder/Bumble design concept, but with movies]
* Search
* User Profile

**Flow Navigation** (Screen to Screen)

* Home
   * Movies/TV
   * Log Out
* Search
   * Movies/TV
   * [optional user story: see Other User Profiles]
* User Profile
    * Watched  > Movies/TV
    * Watch Next  > Movies/TV

## Wireframes
07 July 2020

<img src="wirefram_1.jpg" width=600>


10 July 2020


<img src="IMG-9460.jpg" width=600> <img src="IMG-9461.jpg" width=600> <img src="IMG-9462.jpg" width=600> <img src="IMG-9463.jpg" width=600> 


## Schema 

### Models

Model: User


| Property      | Type          | Description  |
| ------------- |:-------------:| -----|
| email     | String | User’s email they used to sign up and log in |
| password      | String      |   User’s password they used to sign up and login |
| profilePicture      | File      |   User's profile picture |
| watchedMovies	| Array of Pointers to Movie | List of movies a user has signified as watched
| watchNextMovies |	Array of Pointers to Movie| List of movies the user has signified as watchNext
| suggestedMovies	| Array of Pointers to Movie 	| List of movies that the app has deemed suggestible to the user
| watchedShows	| Array of Pointers to Show 	| List of shows a user has signified as watched
| watchNextShows |	Array of Pointers to Show | List of shows the user has signified as watchNext
| suggestedShows |	Array of Pointers to Show	| List of shows that the app has deemed suggestible to the user



Model: Movie


| Property      | Type          | Description  |
| ------------- |:-------------:| -----|
| title     | String | Movie's title |
| cRating |	String |	Movie’s censorship rating
| yearReleased |	DateTime	| The year the movie was release
| description |	String	| A synopsis of the movie and it’s plot
| watched	| BOOL	| Specifies if a USER has signified that the movie was watched.
| userRating |	Pointer | to Rating	User input for movie.
| watchCount |	Number	| Specifies how many USERs have watched this movie.



Model: TV Show


| Property      | Type          | Description  |
| ------------- |:-------------:| -----|
| title     | String | Show's title |
| cRating |	String |	Show’s censorship rating
| seasons |	Number	| The number of seasons a show has
| description |	String	| A synopsis of the show and it’s plot
| watched	| BOOL	| Specifies if a USER has signified that the show was watched.
| userRating |	Pointer | to Rating	User input for show.
| watchCount |	Number	| Specifies how many USERs have watched this show.



Model: Rating


| Property      | Type          | Description  |
| ------------- |:-------------:| -----|
| stars     | Number | User rating of show on a scale of (1-5) |
| wouldWatchAgain |	BOOL |	Specifies if a USER has selected that they would or would not watch this show again.
| author     | Relation <User> | Rating's creator|
| movie     | Relation <Movie> | movie that was rated |
| show     | Relation <TV Show> | tv show that was rated |



## Network Requests and Code Snippets

### Login Screen

   - (Read/GET) Query user where username and password match the user input.
   
```
NSString *username = self.usernameField.text;
NSString *password = self.passwordField.text;

[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {

            if (error != nil){
            
                alert.message = error.localizedDescription;
                
                [self presentViewController:alert animated:YES completion:^{
                
                    }];  
                    
            }
            
            else{
            
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                
            }
        }];

```
### Sign Up Screen
   
   - (Create/POST) Creating a new user.

```
NSString *username = self.usernameField.text;

NSString *password = self.passwordField.text;


[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

           if (error != nil){
           
               alert.message = error.localizedDescription;
               
               [self presentViewController:alert animated:YES completion:^{
               
               }];
               
           }
           
           else{
           
               [self performSegueWithIdentifier:@"loginSegue" sender:nil];
               
           }
           
        }];
```

### User Screen

   - (Read/GET) Query user properties for current user. (Watch Next and Watched)
   
```
    PFQuery *userQuery = [User query];
    
    [postQuery orderByDescending:@"createdAt"];
    
    [postQuery includeKey:@“watchNextMovies”];
    
    [postQuery includeKey:@“watchedMovies”];
    
    [postQuery includeKey:@“watchNextShows”];
    
    [postQuery includeKey:@“watchedShows”];
    

    [postQuery findObjectsInBackgroundWithBlock:^(NSArray User* _Nullable user, NSError * _Nullable error) {
    
        if(user)
        
        {
        }


    }];
```

### Movie/ TV Show Screen

   - (Read/GET) Search if the the movie/TV show is already marked as watched and rated.
    
```   
PFQuery *query [PFQuery queryWithClassName: @“Ratings”];

[query whereKey: @“author” equalTo: [PFUser currentUser]];

[query whereKey: @“movie” equalTo: selectedMovie];


[query findObjectsInBackgroundWithBlock:^(NSArray *ratings, NSError *error) {

    if(ratings){
    
	       for(PFObject *o in objects) 
         {
         
             PFObject *starRating = [o objectForKey: @“stars”];
             
             BOOL *watchAgain = [o objectForKey: @“watchAgain”];
             
          }
          
    }
    
    else
    {   // the user has not marked this movie as watched }

   
}];
```

   - (Read/GET) Search if the the movie/TV show is already marked as Watch Next.
    
```
PFRelation *relation2 = [watcher relationFOrKey:@“watchNextMovies”]

PFQuery *query2 = [relation query2];

[query2 whereKey: @“movie” equalTo: selectedMovie];



[query2 findObjectsInBackgroundWithBlock:^(NSArray User* _Nullable user, NSError * _Nullable error) {

        if(user)
        
        {
        }
        

    }];
```


Creating a Rating

   - (Update/PUT) Add to the user Watched List. (Repeat for TV Shows)

```
PFUser *user = [PFUser currentUser];

PFRelation *relation = [user relationForKey:@“watchedMovies”];

[relation addObject: selectedMovie];

[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

}];

```

  - (Create/POST) Create a Ratings object for the Watched Movie.  (Repeat for TV Shows)
    
```
 (void) addToWatched ( PFObject * _Nullable)movie  withCompletion: (PFBooleanResultBlock _Nullable)completion{
    
    Rating *newRating = [Rating new];
    
    newRating.stars = 
    
    newRating.author = [PFUser currentUser];
    
    newRating.movie = 
    
    newShow.show = 
    
    newPost.watchAgain = 
    
    
    [newRating saveInBackgroundWithBlock:completion];

    PFRelation *relation = [user relationForKey:@“watchedMovies”];
    
    [relation addObject: movie];

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    
     }];
   

}
```

### Settings Screen

   - Logging current user out. 
   
```
[PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {

        //current user is now nil
        
    }];
    
```   
   - (Update/PUT) Change current user's profile picture.
 

- [OPTIONAL: List endpoints if using existing API such as Yelp]
