import React, { useState } from 'react';
import './simple_app.css'; // Import CSS file for styling

const backendUrl = process.env.NODE_ENV === 'development' ? 'http://localhost:8080' : 'https://api.felixcs.xyz';
console.log("Backend URL: " + backendUrl);
console.log("ENV: " + JSON.stringify(process.env));

function Footer() {
  return (
    <footer className="footer">
      <p>Copyright &copy; 2024 Felix Stephenson (definitely not a front end dev). All rights reserved.</p>
      <p><a href="https://github.com/felixcs1/langchain-app">Code Here</a></p>
    </footer>
  );
}


function App() {
  const [inputValue, setInputValue] = useState('');
  const [conversation, setConversation] = useState([]);

  // Extemely hacky parsing of the stream response from the model
  // if only I was better at JS
  const handleSubmitStream = async (event) => {
    event.preventDefault();

    try {
      // console.log(JSON.stringify(conversation) + inputValue)
      const response = await fetch(`${backendUrl}/simple/stream`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        // Send last 200 chars and lastest user input
        // body: JSON.stringify({ input: { question: JSON.stringify(conversation).slice(-200) + inputValue }, config: {}} )
        body: JSON.stringify({ input: { question: inputValue }, config: {}} )
      });

      const reader = response.body.getReader();
      let receivedText = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const decoded = new TextDecoder().decode(value);

        const regex = /"([^"]*)"/g;

        function containsUUID(str) {
          const uuidPattern = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i;
          return uuidPattern.test(str);
        }

        const extractedValues = [];
        let match;
        while ((match = regex.exec(decoded)) !== null) {
          // Dont include UUIDs
          if (containsUUID( match[1])){
            console.log(containsUUID( match[1])); // Output: true
          } else {
            extractedValues.push(match[1]);
          }
        }

        // Get rid of 'run_id' string
        let new_text;
        if (extractedValues[0] === "run_id") {
          new_text = extractedValues.pop()
        } else {
          new_text = extractedValues[0]
        }

        if (new_text && new_text.indexOf("run_id") === -1){
          receivedText += new_text
        }

        // Dont print out \n chars, add quotes instead of \'s
        receivedText = receivedText.replace(/\\n/g, '\n').replace(/\\/g, '"');

        setConversation([...conversation, { user: inputValue, bot: receivedText }]);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleKeyDown = (event) => {
    if (event.key === 'Enter') {
      handleSubmitStream(event);
    }
  };

  return (
    <div className="app-container">
      <div className="container">
        <h1>FelixGPT</h1>
        <div className="conversation-container">
          {conversation.map((msg, index) => (
            <div key={index}>
              <p className="user-message">{msg.user}</p>
              <p className="bot-message">{msg.bot}</p>
            </div>
          ))}
        </div>
        <form onSubmit={handleSubmitStream}>
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Ask something..."
            className="input-field"
            onKeyDown={handleKeyDown}
          />
          <button type="submit" className="submit-button">&#9650;</button>
        </form>
      </div>
      <Footer />
    </div>
  );
}

export default App;


// OLD, Get whole response before updating response on the page
// const handleSubmit = async (event) => {
//   event.preventDefault();

//   try {
//     const response = await fetch(`${backendUrl}/simple/invoke`, {
//       method: 'POST',
//       headers: {
//         'Content-Type': 'application/json'
//       },
//       body: JSON.stringify({ input: { question: inputValue }, config: {}} )

//     });

//     const responseData = await response.json();
//     setResponse(responseData.output); // Assuming response contains a message field
//   } catch (error) {
//     console.error('Error:', error);
//   }
// };
