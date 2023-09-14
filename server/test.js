async function main() {
    const activityId = "7992AA47-FD5C-4505-8E3E-39B1ED2F45AD";
    const resp = await fetch("https://us-central1-slowdown-375014.cloudfunctions.net/cancel_activity_refresh", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            activityId,
        }),
    });
    const data = await resp.json();
    console.log(data);
}

main().catch(console.error);
