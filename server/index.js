const ACTIVITY_ID = "slowdown_status";
const APP_ID = "b1bee63a-1006-42bd-bd66-5a803c64f63c";
const REST_API_KEY = "ZjQ5NmY0MDctZDljNi00ODljLWJjODItMWEzMGI1NWNiZTRl";

async function main() {
    try {
        const options = {
            method: 'POST',
            headers: {
                accept: 'application/json',
                'Content-Type': 'application/json',
                Authorization: `Basic ${REST_API_KEY}}`
            },
            body: JSON.stringify({
                event: 'update',
                event_updates: {
                    isConnected: true 
                },
                name: 'Internal OneSignal Notification Name',
                contents: { en: 'English Message' },
                headings: { en: 'English Message' },
                sound: 'beep.wav',
                stale_date: Date.now() + 1000 * 60 * 60 * 8,
                dismissal_date: Date.now() + 1000 * 60 * 60 * 24 * 7,
                priority: 10
            })
        };
        const resp = await fetch(`https://onesignal.com/api/v1/apps/${APP_ID}/live_activities/${ACTIVITY_ID}/notifications`, options)
        const data = await resp.json()
        console.log(data);
    } catch (error) {
        console.error(error);
    }
}
main();