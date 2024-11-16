import { initializeApp } from 'firebase/app';
import {
    getFirestore,
    collection,
    doc,
    addDoc,
    setDoc,
    getDoc,
    getDocs,
    updateDoc,
    deleteDoc,
  } from 'firebase/firestore';
import express from 'express';
import dotenv from "dotenv"
import fs from "fs"
import { OAuth2Client } from 'google-auth-library';
import { body, param, validationResult } from 'express-validator';
import jwt from 'jsonwebtoken';

const app = express();
app.use(express.json());
dotenv.config();


const firebaseConfig = {
    apiKey: process.env.FIREBASE_API_KEY,
    authDomain: "appointment-booking-1a868.firebaseapp.com",
    projectId: "appointment-booking-1a868",
    storageBucket: "appointment-booking-1a868.firebasestorage.app",
    messagingSenderId: "944857341769",
    appId: "1:944857341769:web:9f3c52fbeacb5da1f58498"
  };


//initialize firebase and google client for id token verification
const client = new OAuth2Client(process.env.GOOGLE_CLIENTID);
const firebase = initializeApp(firebaseConfig);
const db = getFirestore(firebase);

//all routes are verified using google oauth id token
app.post('/user/add', async (req, res) => {
  console.log("/user/add");

  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).send('Unauthorized');

  const { idToken } = req.body;

  try {
    // Verify the ID token
    const payload = await verifyGoogleIdToken(idToken);
    const userId = payload['sub']; // Google user ID
    const userEmail = payload['email'];
    const userName = payload['name'];
    const expiryTime = payload['exp']

    const userDetails = {
      email: userEmail,
      name: userName,
      googleId: userId,
      expiryTime: expiryTime
    }

    // Save user details to Firebase
    const userDocRef = doc(db, 'users', userId);
    const userDoc = await getDoc(userDocRef);

    if (!userDoc.exists()) {
        // Document does not exist, so we can add it
        await setDoc(userDocRef, userDetails);
    } else {
        // Document already exists, handle accordingly (optional)
        console.log(`User with ID ${userId} already exists.`);
    }
    //send user details to our app
    res.status(200).send(userDetails);
  } catch (error) {
    console.error('Error verifying ID token:', error);
    res.status(400).send(`Invalid ID token ${idToken}`);
  }
});


app.post('/booking/add', async (req, res) => {
  console.log("/booking/add");
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).send('Unauthorized');
  
  const idToken = authHeader.split(' ')[1];
  try {
    const payload = await verifyGoogleIdToken(idToken);
    if (payload!=null){
      console.log(req.body)
      const userId = payload['sub']
      
      //add the booking
      await addDoc(collection(db, 'booking'), { ...req.body, googleId: userId });
      res.status(200).send('booking created successfully');
    }else{
      res.status(400).send("payload is null")
    }
  } catch (error) {
    console.log(error)
    res.status(400).send(error.message);
  }
  });

app.get('/booking/all',async(req,res) =>{
  console.log("/booking/all");
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).send('Unauthorized');
  const idToken = authHeader.split(' ')[1];

  try{
    const payload = await verifyGoogleIdToken(idToken);
    if (payload!=null){
      const userId = payload['sub']
      const bookings = await getDocs(collection(db, 'booking'));
      const bookingArray = [];

      if (bookings.empty) {
        res.status(400).send('No Products found');
      } else {
        bookings.forEach((doc) => {
          const booking = doc.data();
          if (booking['googleId'] == userId){
            booking['id'] = doc.id;
            bookingArray.push(booking);
          }    
        });

        res.status(200).send(bookingArray);
      }
    }else{
      res.status(400).send("payload is null")
    }
  } catch (error) {
    console.log(error)
    res.status(400).send(error.message);
  }
})

app.delete('/booking/delete/:id',param("id").isLength(),async (req, res) => {
  console.log("/booking/delete");
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).send('Unauthorized');
  const idToken = authHeader.split(' ')[1];

  const payload = await verifyGoogleIdToken(idToken)
  const result = validationResult(req);
  if(result.isEmpty || payload!=null){
    try {
    const id = req.params.id;
    await deleteDoc(doc(db, 'booking', id));
    console.log(res.status)
    res.status(200).send('booking deleted successfully');
    } catch (error) {
      res.status(400).send(error.message);
    }
  }else{
    if (payload==null){
      res.status(400).send("payload is null")
    }
    res.status(400).send("no id present");
  }
  
})

// app.get('/api/sessions/oauth/google', async (req,res)=>{
//   const code = req.query.code 
//   const url = "https://oauth2.googleapis.com/token"
//   const values = {
//     code, client_id:process.env.GOOGLE_CLIENTID,
//     client_secret: process.env.GOOGLE_CLIENTSECRET,
//     redirect_uri: process.env.GOOGLE_OAUTH_REDIRECT_URL,
//     grant_type: "authorization_code",
//   }
//   console.log(values)

//   try{
//     const response = await axios.post(url,qs.stringify(values),
//   {
//     headers: {
//       'Content-Type': 'application/x-www-form-urlencoded',
//     }
//   })
//   console.log(response.data)
//   res.status(200).send(response.data)
//   }catch(e){
//     console.log("error",e)
//   }
// })

app.get('/',(req,res)=>{
  return res.send("hello")
})

app.get('/api/keys',(req,res)=>{
  console.log('/api/keys/')
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).send('Unauthorized');

  jwt.verify(token, getPrivateKey(), (err, decoded) => {
    if (err) {
      console.log(err)
      return res.status(401).send('Unauthorized');
    }else{
      console.log("verified")
      const googleClientId = process.env.GOOGLE_CLIENTID
      const IOSgoogleClientId = process.env.IOS_CLIENT_ID
      const googleIssuer = process.env.GOOGLE_ISSUER
      const redirectURI = process.env.GOOGLE_REDIRECT_URI
      console.log(googleClientId,IOSgoogleClientId,googleIssuer,redirectURI);

      return res.status(200).json({
        googleClientId,
        IOSgoogleClientId,
        googleIssuer,
        redirectURI,
      })
    } // Pass control to the next middleware or route handler
  });
  
})

app.get("/cert",async (req,res)=>{
  console.log("/cert");
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).send('Unauthorized');
  
  jwt.verify(token, getPrivateKey(), (err, decoded) => {
    if (err) {
      console.log(err)
      return res.status(401).send('Unauthorized');
    }else{
      console.log("verified")
      // const cert = fs.readFileSync('./certi.pem')
      const cert= fs.readFileSync('/etc/ssl/nodecerts/cert.pem')

      return res.status(200).json({
        cert
      })
    } // Pass control to the next middleware or route handler
  });
  
})

app.post('/save-key', (req, res) => {
  console.log('/save-key');
  try{
    const { privateKey } = req.body;
      if (!privateKey) {
        return res.status(400).send('Private key is missing');
      }

      // Save the private key securely (use a better method for production)
      const filePath = './privateKey.pem';
      fs.writeFileSync(filePath, privateKey, { encoding: 'utf8', mode: 0o600 });
      
      res.status(200).send('Private key saved successfully');
  }catch(e){
    console.log(e)
  }
 
});



app.listen(3000, () => {
  console.log('Server started on port 3000');
});


async function verifyGoogleIdToken(idToken){
  try{
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENTID,
    });

    const payload = ticket.getPayload();
    console.log(payload)
    return payload;
  }catch(error){
    console.log(`couldnt verify ${error}`)
    // if current time has exceeded token expiry then payload should be null
    return null;
    // throw error;
  }
  
}

function getPrivateKey(){
  const privateKey = fs.readFileSync('./privateKey.pem', 'utf8');

  // console.log(privateKey)
  return privateKey;
}