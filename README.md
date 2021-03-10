<h1 align="center"> YoYo Messenger </h1>

<p align="center">
  <img src="https://img.shields.io/badge/Developer-Vishnu_Divakar-orange" />
  <img src="https://img.shields.io/badge/OpenSource-Always-green" />
  <img src="https://img.shields.io/badge/Users-3-yellow" />
  <img src="https://img.shields.io/badge/DevState-Phase_1-blue" />
</p>

<p align="justify">
An iOS messaging application for people to communicate. Phase 1 of the development is to get all basic features of a messaging application. Users can add friends and chat with them real time. It should be equipped with a basic story system when user can post a story and friends can view them in 24 hrs of posting the story. It is equipped with basic user settings like changing profile picture, reseting password and logout from the application.
</p>

<h3>Landing Page</h3>
<div>
  <p align="justify">
    Application when launched the user will be presented with the below landing page. User can login or create an account. It is intended as a brand page with application name and motto.
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/landing_page.PNG" />
  </p>
</div>

<h3>Create Account Page</h3>
<div>
  <p align="justify">
    Users should register with the platform to be a valid user. We collect information like name, email, password, date of birth and a profile picture. User need to be at least 14 years old to register. Once user register successfully, an automated verification email will be send to your registered email, user should be verified before logging in.
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/create_account.PNG" />
  </p>
</div>

<h3>Login Page</h3>
<div>
  <p align="justify">
    User need to use registered email and password to login to the application. If login is successful, application will store credentials in core data and later use it to automatically login the user if the user biometric security is successful. User can generate a reset password email by providing the registered email account.
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/signin_page.PNG" />
  </p>
</div>

<h3>Chats Page</h3>
<div>
  <p align="justify">
    Chat view shows all chats with your friends sorted by latest message. If the user want to send message to a new friend, user can compose message by selecting friend and send messages. User can send plain text, video, images and audio format. Real time communication with vibration feedback for new messages. User can see whether their friends seen the message or not.
  </p>
  <p align="center">
    <div>
      <h4>Default chat view</h4>
      <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/chat_view.png" />
    </div>
    <div>
      <h4>Send messages but not seen by friend</h4>
      <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/UnSeenMessages.png" />
    </div>
    <div>
      <h4>New messages</h4>
      <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/new_message_view.png" />
    </div>
    <div>
      <h4>Friend's message view</h4>
      <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/friend_message_view.png" />
    </div>
    <div>
      <h4>Messages seen by friend</h4>
      <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/message_seen_view.png" />
    </div>
  </p>
</div>

<h3>Story Page</h3>
<div>
  <p align="justify">
    Users can post stories either an image or a video of less than 60 seconds. All stories expire after 24 hours. Users can skip to previous or next story by tapping left or right side of the screen. User can pause the story by holding the screen and can dismiss the view by swiping down. User can view the viewers of story when user is viewing own stories. All story showcases a minimum details like title of the story, duration of the story and total views of the story.
  </p>
  <p align="center">Story Demo</p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/story.gif" />
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/story_view.png" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/friends_story.png" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/own_story.png" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/viewed_by.png" />
  </p>
</div>

<h3>Settings Page</h3>
<div>
  <p align="justify">
    User can change profile picture, name, request for a password reset and logout from the application from the settings page.
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/settings_page.PNG" />
  </p>
</div>

<h3>Friends Page</h3>
<div>
  <p align="justify">
    The friends tab of application present user with default view of a list of friends. User can add friends by searching for other users by partially providing their name or email and send friend request to them. User have couple of actions they can perform on his/her friends like cancel the friend request, unfriend, block and unblock.  
  </p>
  <p align="center">
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/cancel_friend_request.PNG" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/normal_friend_view.PNG" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/unblock_view.PNG" />
    <img src="https://github.com/vishnudivakar31/YoYo-Messenger/blob/main/screenshots/search_friends.PNG" />
  </p>
</div>

<h4>Phase 1 - Pending Features</h4>

```diff
+ Attachment for Chats (Image, Audio and Video)
+ Audio Call
+ Video Call
```
