async function main() {
    const resp = await fetch("https://us-central1-slowdown-375014.cloudfunctions.net/register_unpause", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            activityId: "slowdown_status",
            sendDate: Date.now(),
        }),
    });
    const data = await resp.json();
    console.log(data);
}

main().catch(console.error);
