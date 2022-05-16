// This only works in browsers, not NodeJS
class FatesWS {
	constructor(id, token, sendAll, sendNone, bot) {
		this.id = id
		this.token = token
		this.sendAll = sendAll
		this.sendNone = sendNone
		this.bot = bot
		this.hooks = {
			"ready": this.ready,
			"identity": this.identity,
			"fallback": this.fallback,
			"event": this.event
		}
		this.websocket = null
	}

	start() {
		this.websocket = new WebSocket("wss://fateslist.xyz/api/dragon/ws")
		this.websocket.onmessage = (event) => {
			let data = event.data.split("\x1f")
			data.forEach(dat => {
				if(dat == "") {
					// It is possible for the event to be empty so ignore those
					return
				}
				let json = JSON.parse(dat)
				console.log({json}, json.code)
				try {
					let hook = this.hooks[json.code]
					if(hook) {
						hook(this, json)
					} else {
						console.log(json.code, "hook not found")
					}
				}
				catch (error) {
					console.log(error)
					// This is normal do nothing
				}
			})
		}
	}

	ready(cls, data) {
		console.log(data)
	}

	fallback(cls, data) {
		console.log(data)
	}

	identity(cls, data) {
		console.log(data)
		let identityPayload = {
			id: cls.id,
			token: cls.token,
			send_all: cls.sendAll,
			send_none: cls.sendNone,
			bot: cls.bot
		}
		console.log({identityPayload})
		cls.websocket.send(JSON.stringify(identityPayload))
	}

	event(cls, data) {
		console.log(data)
	}

	close(code) {
		if(!code) {
			code = 1000
		}
		this.websocket.close(code)
	}
}

class EventsClass {
	constructor() {
		this.VoteEvent = 0
		this.ViewEvent = 16
		this.InviteEvent = 17
	}
}

var Events = new EventsClass()
