# finalmicrophone
To set this up, the safest way is so that the laptop doesn't hang and you don't waste a day in it.
install android studio, 
install flutter,
put flutter sdk path /bin/cache/dart-sdk in the dart sdk in the android studio settings
install flutter and dart plugins in studio settings
then, clone the project
make a new flutter project under the same name,
run the gradle first so that it shows in the mobile (counter app),
then,
tools, SDK manager, install cmd line tools,
install Firebase cli, firebase login,( google auth didn't work, so just reset the password using Gmail).
copy lib folder, pubspec.yml and lock file, google.json file to the new project and flutter run (after closing other apps 
to run without lagging).

Tried to apply SOLID principles to my app, but since I am using ChangeNotifier, there is no need. It is efficient as it is.
