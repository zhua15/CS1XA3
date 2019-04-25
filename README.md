# Project03 - CubeMaker

Andrew Zhu

## Initialization

To begin, first install all the python packages in the requirements.txt
**pip install -r requirements.txt

## Starting the Server

From ~/CS1XA3/Project03 run
**source/activate

and then go into the django_project folder
**cd django_project

and then activate the server
**python manage.py runserver localhost:10065

## Creating an Account

To start playing, you will have to first create an account. Each account username must be unique, and using a non-unique username will result in a error appearing below the signup button
To sign up, click the **Not a user?** in order to navigate to the sign up screen
To login if you're already a user, click **Already a user?** in order to navigate to the login screen

## Playing the Game 

To play the game, simply click and drag around platforms to move them. Dragging them into the trash bin box will delete them
To add a shape, simply input a valid number into the "L" text box and the "W" text box. This will set the length and the width, and afterwards select a colour from the colour menu and click add to add the platform into the middle of the screen. These platforms are also draggable.
The colour with a **V** over it is the victory platform, players will win as soon as any player lands on top of that coloured platform
To move the characters, use WASD for the purple square and arrow keys for the blue square. The characters will collide with the platforms, but not with each other. The code for players 3 and 4 already exists for future real-time multiplayer implementation.
To reset all platforms, click the **New** button
To save all platforms, click the **Save** button
To load all platforms, click the **Load** button

Save files are user specific, and will only hold one save file per user.
To share maps with friends, tell them the username and the password for them to access your levels

## Errors
*Bad Status 502 - The server is offline
*Bad Status 500 - Username not unique
*Network Error - No internet
*Bad Body - Saving/Loading error

# Features
Saving - saves the platforms as a json by performing a post request to the server
Loading - loads the platforms by performing a get request to the server
Login - allows an existing user to login
New User - creates and saves a new user
Platform moving - allows the user to drag platforms wherever they want
Platform addition - allows the user to add new custom platforms
Platform deletion - allows the user to delete specific paltforms
New map - deletes all platforms
Player movement - allows players to move freely using the built in physics engine
Collision detection - allows players to interact with platforms
