import React, { useState } from 'react';
import './simple_app.css'; // Import CSS file for styling


const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8080';
// const backendUrl = process.env.NODE_ENV === 'development' ? 'http://localhost:3000' : 'http://goals-app-backend-alb-360739314.eu-west-2.elb.amazonaws.com';
console.log("Backend URL: " + backendUrl);
console.log("ENV: " + JSON.stringify(process.env));

function App() {
  const [inputValue, setInputValue] = useState('');
  const [response, setResponse] = useState('');

  // Get whole response before updating response on the page
  const handleSubmit = async (event) => {
    event.preventDefault();

    try {
      const response = await fetch(`${backendUrl}/simple/invoke`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ input: { question: inputValue }, config: {}} )

      });

      const responseData = await response.json();
      setResponse(responseData.output); // Assuming response contains a message field
    } catch (error) {
      console.error('Error:', error);
    }
  };

  // Stream response to page
  // Very crude processing to make the streaming output somewhat formatted
  const handleSubmitStream = async (event) => {
    event.preventDefault();

    try {
      const response = await fetch(`${backendUrl}/simple/stream`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ input: { question: inputValue }, config: {}} )
     });

      // Create a ReadableStream to read the response data as it arrives
      const reader = response.body.getReader();
      let receivedText = '';

      // Read data from the stream as chunks and update the state with each chunk
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        // Convert the Uint8Array chunk to a string and update the state
        const decoded = new TextDecoder().decode(value);

        const regex = /"([^"]*)"/g;
        const extractedValues = [];
        let match;
        while ((match = regex.exec(decoded)) !== null) {
            extractedValues.push(match[1]);
          }

        let new_text;
        if (extractedValues[0] === "run_id") {
            new_text = extractedValues.pop()
        } else {
            new_text = extractedValues[0]
        }

        console.log(new_text)

        if (new_text && new_text.indexOf("run_id") === -1){
            receivedText += new_text
        }

        setResponse(receivedText);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div className="container">
      <h1>Simple React App</h1>
      <form onSubmit={handleSubmitStream}>
        <label>
          Input:
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            className="input-field"
          />
        </label>
        <button type="submit" className="submit-button">Submit</button>
      </form>
      <div className="response-container">
        <h2>Response:</h2>
        <p className="response-text">{response}</p>
      </div>
    </div>
  );
}

export default App;
