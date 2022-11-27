# <img src="src/resultScreenshot/twitterMockery.png?raw=true" width="70" height="60" />Blue Bird Mockery <br>
##### <i> Lohit Bhambri(lohit.bhambri@ufl.edu) </i>
##### <i> Imthiaz Hussain (imthiazh.hussain@ufl.edu) </i>
<p>
COP5615 The goal of this project is to develop a Twitter <i>"like"</i> simple functions in Erlang
</p>

## How to run the project

We are using distributed erlang functionality to achieve a client-server model. 
To store the information we are using ```mnesia``` which is an ```object store``` that store information in ```key-value record pair```. 
<br>

Currently, we are using a single system to perform the simulation. 
We can use multiple system as well, we just need to set cookie when we simulate both client and server 
using command <br>
```erlang:set_cookie(<<cookie-name>>)```

## Initialize a server
We have a single server node <br> 
```Server@127.0.0.1```
```

```

## Initialize a client
Here we have simulated four client nodes <br>
```A. Client-abc@127.0.0.1```
```aidl

```

```B. Client-pqr@127.0.0.1```
```aidl

```

```C. Client-stu@127.0.0.1```
```aidl

```

```D. Client-vwx@127.0.0.1```
```aidl

```
Here is the output on our server once the handshake is successfully established between client and 
server <br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")<br>

## Register the clients
Once server and client relationship is established between the client and server nodes,
our first step will be to register client 

```A. Client-abc@127.0.0.1```
```aidl

```
Output once our user ```abc``` is successfully registered on the server<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```B. Client-pqr@127.0.0.1```
```aidl

```
Output once our user ```pqr``` is successfully registered on the server<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```C. Client-stu@127.0.0.1```
```aidl

```
Output once our user ```stu``` is successfully registered on the server<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```D. Client-vwx@127.0.0.1```
```aidl

```
Output once our user ```vwx``` is successfully registered on the server<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

## Follow the user
Here users ```pqr``` and client ```stu``` will follow user ```abc```.
User ```vwx``` will not follow anyone right now

```Client-pqr@127.0.0.1```
```aidl

```
Output once our user ```pqr``` is following user ```abc```<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```Client-stu@127.0.0.1```
```aidl

```
Output once our user ```stu``` is following user ```abc```<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

## Post a tweet
Here user ```abc``` will post a tweet, it will be visible to both user 
```pqr``` and user ```stu``` once they will check their tweet

```Client-abc@127.0.0.1```
This client will post two tweets
````aidl

````
The tweets will be added to the message-box of user ```pqr``` and user ```stu
<br>

```Server@127.0.0.1```<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```Client-pqr@127.0.0.1```<br>
This client will check the tweets available in the message-box. 
<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

```Client-stu@127.0.0.1```<br>
This client will check the tweets available in the message-box.
<br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
<br>

## Post Tweet to the user who is not following using @ annotation <br>

Our user-id is a three character user-id, so in order to post tweet to 
non-following user, we need to use following annotation in our tweets ```@<<user-id>>```
<br>

User ```vwx``` will post a tweet and use annotation ```@abc```.
This tweet will be available inside the message box of user ```abc```.
<br>

```Client-vwx@127.0.0.1```
```aidl

```
The message will be available inside the message box of user ```abc``` <br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")

## Retweet the tweet
Now user ```abc``` will retweet the message available inside it's message queue.
This message will be added inside the message-box of user ```pqr``` 
and user ```stu```, who are the followers of user ```abc```
<br>

```Client-abc@127.0.0.1```
```aidl

```
The re-tweeted message will be available inside the message box of 
user ```pqr``` and user ```stu``` <br>
![Alt text](src/resultScreenshot/inputScreenshot.jpg?raw=true "Result")
