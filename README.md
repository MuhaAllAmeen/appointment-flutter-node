# appointment

A Booking app created using flutter and node js.
The backend server is hosted using an aws ec2 instance and the requests are sent through the domain <b>https://appointment.crabdance.com</b>
Excuse the domain (its the only free one I could get)
Firebase Database is used to store data from the server.
Note that, even though there are firebase files present in the flutter side, they are not used at all. They were created at first and I did not want to delete them. So, the app works without firebase.
All firebase methods are run in the node js server.
![image](https://github.com/user-attachments/assets/60c5551d-95f4-4f44-a5a2-38c95bb8a795)
![image](https://github.com/user-attachments/assets/9f35cb60-20df-47c0-8eec-832af93a92a5)

Please note that this app might not work for the IOS for the moment as I dont have an apple pc that can emulate an IPhone to test.
I am only saying this because I have and can not test google oauth for IOS. But leaving the login out of the way, the rest of the app should perfectly for IOS and Android.
If there are any server issues then please raise an issue as I am running an aws machine and it can shut down if it goes above my budget since it is a paid service.

Working of the app(click on the link if video is not displayed):
https://github.com/user-attachments/assets/17195e54-9b9e-4945-b5a3-2e86d032bceb

 ● SecureAuthentication (OAuth 2.0):
User can login using their google account.
Google OAuth, on successful login, will respond with an id token which contains the user details and the token details.
Along with it, it also sends an access and refresh tokens.
If there is no refresh token or if id token has expired then user has to sign in again.
All the tokens are safely secured using flutter_secure_storage.

 ● SecureStorage of Sensitive Data:
 It is not secure to store the api keys in the client side. So, all the api keys are retrived from the server and stored using flutter_secure_storage.
 
  ● SecureNetwork Communication:
  Since the backend server is hosted under the domain appointment.crabdance.com, an ssl certificate has been generated and verified using lets encrypt. Further, certificate pinning has also been implemented by creating a secure http client. The certificate is also stored in the server and retrieved by the app. Network errors are handled showing appropriate dialogs and snackbars if there are any errors.
  
   ● Input Validation and Sanitization:
   A form has been created to collect data.
   All the data is then validated (for eg, phone number contains 10 digits or email contains @)
   even on the server side, the id is validated before deletion of any booking.
   Mainly, all fields are ensured to not have any html code or script tags.
   
  ● Biometric Authentication (Optional):
  
https://github.com/user-attachments/assets/247c52d0-07f0-4972-820c-c1040ab51c0f

User can login using their biometrics if it is possible or else google login will be shown.
User has the choice to login using fingerprint/face id or pin/password
Please not that google login is necessary if the id token has expired.

 ● CodeReviewfor Security:
I do not understand the question that asked to review a provided codebase.
If I was asked to review my own codebase then I can say that there are no api keys or ids stored insecurely. There are no hardcoded secrets. 

 ● ManagingThird-Party Libraries:
all dependencies are checked for updation and they are updated recently.

 ● DataEncryption (at Rest and in Transit):
 Since flutter_secure_storage is used for storing data, all data is encrypted using AES encryption. 
since we have an ssl certificate attached to our http client that makes the requests, all data sent back and forth is encrypted using ssl
  

