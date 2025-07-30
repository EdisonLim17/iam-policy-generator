let backend_url = "";
let google_client_id = "";
let token = null;

fetch('/config.json')
  .then(response => response.json())
  .then(config => {
    backend_url = config.backend_url;
    google_client_id = config.google_client_id;
    console.log('Backend URL:', backend_url);

    // Auth token check here so backend_url is ready before fetchHistory is called
    const urlParams = new URLSearchParams(window.location.search);
    const accessToken = urlParams.get("token");
    const email = urlParams.get("email");
    const picture = urlParams.get("picture");

    if (accessToken) {
      token = accessToken;
      showUserInfo({ email, picture });
      fetchHistory();
    }
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

// Show user info
function showUserInfo(user) {
  document.getElementById("authSection").style.display = "none";
  document.getElementById("userInfo").style.display = "flex";
  document.getElementById("historySection").style.display = "flex";
  document.getElementById("userPicture").src = user.picture;
  document.getElementById("userEmail").textContent = user.email;
}

// Fetch user history
async function fetchHistory() {
  try {
    const response = await fetch(`${backend_url}/history`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    const list = document.getElementById("historyList");
    list.innerHTML = "";
    
    if (Array.isArray(data)) {
      data.forEach(item => {
        const li = document.createElement("li");

        const summary = document.createElement("div");
        summary.textContent = item.prompt;
        summary.style.cursor = "pointer";
        summary.style.fontWeight = "bold";

        const toggleBtn = document.createElement("button");
        toggleBtn.textContent = "Load";
        toggleBtn.style.marginLeft = "1rem";
        toggleBtn.style.background = "#fbbf24";
        toggleBtn.style.border = "none";
        toggleBtn.style.borderRadius = "4px";
        toggleBtn.style.padding = "2px 8px";
        toggleBtn.style.cursor = "pointer";
        toggleBtn.style.fontSize = "12px";

        toggleBtn.addEventListener("click", () => {
          document.getElementById("prompt").value = item.prompt;
          editor.setValue(JSON.stringify(item.policy, null, 2));
        });

        li.appendChild(summary);
        li.appendChild(toggleBtn);
        list.appendChild(li);
      });
    }
  } catch (error) {
    console.error("Error fetching history:", error);
    // Optionally show a user-friendly error message here
  }
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
