let backend_url = "";
let google_client_id = "";
let token = null;

fetch('/config.json')
  .then(response => response.json())
  .then(config => {
    backend_url = config.backend_url;
    google_client_id = config.google_client_id;
    console.log('Backend URL:', backend_url);
  })
  .catch(err => {
    console.error('Failed to load config.json', err);
  });

let editor;

require.config({ paths: { vs: "https://unpkg.com/monaco-editor@0.45.0/min/vs" } });
require(["vs/editor/editor.main"], function () {
  editor = monaco.editor.create(document.getElementById("editor"), {
    value: `{
  "Version": "2012-10-17",
  "Statement": []
}`,
    language: "json",
    theme: "vs-dark",
    readOnly: true,
    minimap: { enabled: false },
  });
});

// Sign in with Google
document.getElementById("googleSignInBtn").addEventListener("click", () => {
  const clientId = google_client_id;
  const redirectUri = "https://iampolicygenerator-backend.edisonlim.ca/oauth2/callback";
  const scope = "openid email profile";

  const oauthUrl = `https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&scope=${encodeURIComponent(scope)}&access_type=offline&prompt=consent`;

  window.location.href = oauthUrl;
});

// Check for auth code
const urlParams = new URLSearchParams(window.location.search);
const accessToken = urlParams.get("token");
const email = urlParams.get("email");
const picture = urlParams.get("picture");

if (accessToken) {
  token = accessToken;
  showUserInfo({ email, picture });
  fetchHistory();
}

// Show user info
function showUserInfo(user) {
  document.getElementById("authSection").style.display = "none";
  document.getElementById("userInfo").style.display = "flex";
  document.getElementById("historySection").style.display = "block";
  document.getElementById("userPicture").src = user.picture;
  document.getElementById("userEmail").textContent = user.email;
}

// Fetch user history
function fetchHistory() {
  fetch(`${backend_url}/history`, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  })
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById("historyList");
      list.innerHTML = "";
      data.forEach(item => {
        const li = document.createElement("li");
        li.textContent = `${item.prompt} → Policy saved`;
        list.appendChild(li);
      });
    });
}

// Generate IAM Policy
document.getElementById("generateBtn").addEventListener("click", async () => {
  const prompt = document.getElementById("prompt").value.trim();
  if (!prompt) return;

  const button = document.getElementById("generateBtn");
  button.disabled = true;
  button.textContent = "Generating...";

  try {
    const response = await fetch(`${backend_url}/generate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Error generating policy: ${response.status} ${errorText}`);
    }

    const data = await response.json();
    editor.setValue(data.iam_policy || "// Invalid response");

    if (token) {
      const saveResponse = await fetch(`${backend_url}/save-history`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ prompt, policy: data.iam_policy })
      });

      if (!saveResponse.ok) {
        const errorText = await saveResponse.text();
        throw new Error(`Error saving history: ${saveResponse.status} ${errorText}`);
      }
      
      fetchHistory();
    }
  } catch (error) {
    console.error("Error generating policy:", error);
    editor.setValue("// Error generating IAM policy");
  } finally {
    button.disabled = false;
    button.textContent = "Generate Policy";
  }
});
