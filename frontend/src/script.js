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
  document.getElementById("authPlaceholder").style.display = "none";
  document.getElementById("userInfo").style.display = "flex";
  document.getElementById("historyListContainer").style.display = "block";
  document.getElementById("userPicture").src = user.picture;
  document.getElementById("userEmail").textContent = user.email;
  document.getElementById("signout-btn").style.display = "block";
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

        // History summary that you click to load
        const summary = document.createElement("div");
        summary.classList.add("truncated-text");
        summary.textContent = item.prompt;
        summary.style.cursor = "pointer";
        summary.style.fontWeight = "bold";
        summary.style.padding = "0.5rem 0";

        summary.addEventListener("click", () => {
          document.getElementById("prompt").value = item.prompt;

          try {
            const parsed = typeof item.policy === "string" ? JSON.parse(item.policy) : item.policy;
            editor.setValue(JSON.stringify(parsed, null, 2));
          } catch (e) {
            console.error("Failed to load policy:", e);
            editor.setValue("// Invalid JSON format");
          }
        });

        li.appendChild(summary);
        list.appendChild(li);
      });
    }
  } catch (error) {
    console.error("Error fetching history:", error);
    // Optionally show a user-friendly error message here
  }
}

// Generate IAM Policy
document.getElementById("generate-btn").addEventListener("click", async () => {
  const prompt = document.getElementById("prompt").value.trim();
  if (!prompt) return;

  const button = document.getElementById("generate-btn");
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
    // try {
    //   const parsed = typeof data.iam_policy === "string" ? JSON.parse(data.iam_policy) : data.iam_policy;
    //   editor.setValue(JSON.stringify(parsed, null, 2));
    // } catch (e) {
    //   console.error("Failed to generate policy:", e);
    //   editor.setValue("// Invalid response");
    // }

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

// Handle Enter key for generating policy
document.getElementById("prompt").addEventListener("keydown", function (e) {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault(); // Prevent newline
    document.getElementById("generate-btn").click(); // Simulate button click
  }
});

// Sign out functionality
document.getElementById("signout-btn").addEventListener("click", () => {
  // Clear token
  token = null;

  // Hide user info and history panel
  document.getElementById("userInfo").style.display = "none";
  document.getElementById("historyListContainer").style.display = "none";

  // Hide sign-out button
  document.getElementById("signout-btn").style.display = "none";

  // Show sign-in section
  document.getElementById("authPlaceholder").style.display = "flex";

  // Clear editor and prompt inputs (optional)
  editor.setValue(`{
  "Version": "2012-10-17",
  "Statement": []
}`);
  document.getElementById("prompt").value = "";

  // Optionally clear URL params for token/email/picture to avoid auto sign-in on refresh
  if (window.history.replaceState) {
    const url = new URL(window.location);
    url.searchParams.delete('token');
    url.searchParams.delete('email');
    url.searchParams.delete('picture');
    window.history.replaceState({}, document.title, url.toString());
  }
});
