import { useState } from "react";

// Comme nginx fait office de proxy inverse de /app/api vers le conteneur backend,
// le frontend peut envoyer ses requêtes avec un chemin relatif à l'origine depuis laquelle on y accède
// (Coder localhost en dur empêcherait l'accès depuis un autre hôte, par exemple dans un Codespace)
const API_URL = "/app/api";

export function App() {
  const [inputText, setInputText] = useState("");
  const [result, setResult] = useState("");

  const handleSend = async () => {
    if (!inputText) return;

    try {
      const response = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ input_text: inputText }),
      });

      if (!response.ok) {
        throw new Error("Une erreur API est survenue");
      }

      const data = await response.json();
      setResult(`Réponse : ${data.reply}`);
    } catch (error) {
      console.error(error);
      setResult("La communication a échoué.");
    }
  };

  return (
    <>
      <h1>Docker Compose Demo</h1>
      <input
        type="text"
        placeholder="Saisissez un message"
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
      />
      <button onClick={handleSend}>Envoyer</button>
      <p>{result}</p>
    </>
  );
}
