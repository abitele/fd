db = db.getSiblingDB('test');
db.users.insert({ name: "Francis", email: "fdzabeng.obdf@gmail.com" });

db = db.getSiblingDB('analytics');
db.events.insert({ type: "click", timestamp: new Date() });