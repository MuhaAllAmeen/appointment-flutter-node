import { initializeApp } from 'firebase/app';
import {
    getFirestore,
    collection,
    doc,
    addDoc,
    getDoc,
    getDocs,
    updateDoc,
    deleteDoc,
  } from 'firebase/firestore';
import express from 'express';
import axios from 'axios';
import qs from "qs"
import dotenv from "dotenv"
import fs from "fs"
import https from "https"

const app = express();
app.use(express.json())
dotenv.config()


const firebaseConfig = {
    apiKey: "AIzaSyDcmWBru9eebLTke9bmstbaYP9YNiU8XDM",
    authDomain: "appointment-booking-1a868.firebaseapp.com",
    projectId: "appointment-booking-1a868",
    storageBucket: "appointment-booking-1a868.firebasestorage.app",
    messagingSenderId: "944857341769",
    appId: "1:944857341769:web:9f3c52fbeacb5da1f58498"
  };



const firebase = initializeApp(firebaseConfig);
const db = getFirestore(firebase);
app.post('/booking/add', async (req, res) => {
  try {
    console.log(req.body)
    // const data = new Map(Object.entries(req.body));;
    
    await addDoc(collection(db, 'booking'), req.body);
    res.status(200).send('booking created successfully');
  } catch (error) {
    res.status(400).send(error.message);
  }
  });

app.get('/booking/all',async(req,res) =>{
  try{
    const bookings = await getDocs(collection(db, 'booking'));
    const bookingArray = [];

    if (bookings.empty) {
      res.status(400).send('No Products found');
    } else {
      bookings.forEach((doc) => {
        const booking = doc.data();
        booking['id'] = doc.id;
        bookingArray.push(booking);
      });

      res.status(200).send(bookingArray);
    }
  } catch (error) {
    res.status(400).send(error.message);
  }
})

app.delete('/booking/delete/:id',async (req, res) => {
  try {
    const id = req.params.id;
    await deleteDoc(doc(db, 'booking', id));
    console.log(res.status)
    res.status(200).send('booking deleted successfully');
  } catch (error) {
    res.status(400).send(error.message);
  }
})

app.get('/api/sessions/oauth/google', async (req,res)=>{
  const code = req.query.code 
  const url = "https://oauth2.googleapis.com/token"
  const values = {
    code, client_id:process.env.GOOGLE_CLIENTID,
    client_secret: process.env.GOOGLE_CLIENTSECRET,
    redirect_uri: process.env.GOOGLE_OAUTH_REDIRECT_URL,
    grant_type: "authorization_code",
  }
  console.log(values)

  try{
    const response = await axios.post(url,qs.stringify(values),
  {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    }
  })
  console.log(response.data)
  res.status(200).send(response.data)
  }catch(e){
    console.log("error",e)
  }
})

app.get('/',(req,res)=>{
  return res.send("hello")
})

app.listen(3000, () => {
  console.log('Server started on port 3000');
});

  