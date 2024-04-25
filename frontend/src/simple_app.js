import React, { useState } from 'react';
import './simple_app.css'; // Import CSS file for styling

const backendUrl = process.env.NODE_ENV === 'development' ? 'http://localhost:8080' : 'https://api.felixcs.xyz';
console.log("Backend URL: " + backendUrl);
console.log("ENV: " + JSON.stringify(process.env));

function Footer() {
  return (
    <footer className="footer">
      <p>Copyright &copy; 2024 Felix Stephenson (definitely not a front end dev)</p>
      <p><a href="https://github.com/felixcs1/langchain-app">Code Here</a></p>
    </footer>
  );
}

function App() {
  const [inputValue, setInputValue] = useState('');
  const [conversation, setConversation] = useState([]);
  const [selectedType, setSelectedType] = useState('chat'); // Default to 'chat'

  const handleTypeChange = (type) => {
    console.log("Handle type change: " + type);
    setSelectedType(type);
  };
  console.log("Selected type: " + selectedType);

  const handleSubmitStream = async (event) => {
    event.preventDefault();

    try {
      const response = await fetch(`${backendUrl}/${selectedType}/stream`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
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
          // Don't include UUIDs
          if (containsUUID(match[1])){
            console.log(containsUUID(match[1])); // Output: true
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

        // Don't print out \n chars, add quotes instead of \'s
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
        <h1>Felix.ai</h1>
        <div className="type-toggle">
          <label>
            <input
              type="radio"
              name="chat-type"
              value="chat"
              id="chat"
            //   checked={selectedType === 'chat'}
              onChange={() => handleTypeChange('chat')}
            />
            Chat
          </label>
          <label>
            <input
              type="radio"
              name="chat-type"
              value="interview"
              id='interview'
            //   checked={selectedType === 'interview'}
              onChange={() => handleTypeChange('interview')}
            />
            Interview
          </label>
        </div>
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
            placeholder={selectedType === 'interview' ? 'Interview Felix...' : 'Ask something...'}
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
