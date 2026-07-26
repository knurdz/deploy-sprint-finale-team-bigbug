const emailStatus = {
  task: 'T16',
  provider: 'resend',
  configured: Boolean(process.env.RESEND_API_KEY),
  secretRedacted: true,
};

// Print the required evidence
console.log('Email Status Evidence:', JSON.stringify(emailStatus, null, 2));

async function sendAlert() {
  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) {
    console.log("No RESEND_API_KEY found in environment. Performing dry-run.");
    return;
  }
  
  console.log("Sending email to judges@knurdz.org via Resend...");
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'Deploy Sprint <alerts@knurdz.org>',
        to: 'judges@knurdz.org',
        subject: 'Deploy Alert - T16',
        html: '<p>Deployment process triggered.</p>'
      })
    });
    
    if (res.ok) {
        const data = await res.json();
        console.log("Resend API response:", data);
        console.log("Email sent successfully.");
    } else {
        console.error("Resend API error:", res.status, res.statusText);
        const errData = await res.text();
        console.error(errData);
    }
  } catch (err) {
    console.error("Failed to send email:", err);
  }
}

sendAlert();
