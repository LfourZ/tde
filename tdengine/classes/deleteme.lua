	fn = function(message)
			local _, server = string.match(message.content, "(%S+) (.*)")
			local data = ""
			local s = {}
			local admins = https.request({host="skufs.net",path="/admins"}, function (res)
				res:on("data", function (chunk)
					data = data..chunk
				end)
				res:on("end", function()
					local root = htmlparser.parse(data)
					local l1 = root:select(".staff_column")
					for _, e1 in ipairs(l1) do
						local server = e1:select("h2")[1]:getcontent()
						s[server] = s[server] or {}
						local l2 = e1:select("li")
						for _, e2 in ipairs(l2) do
							local onlineStatus = e2:select("div")[1]
							s[server][e2:select("a")[1]:getcontent()] = {
								online = getOnline(onlineStatus.classes),
							}
						end
					end
					local msg = "```"
					for k, v in pairs(s) do
						msg = msg..k.."\n"
						for i, j in pairs(v) do
							if j.online then
								msg = msg..i.."\n"
							end
						end
					end
					msg = msg.."```"
					return message:reply(msg))
				end)
			end)
			admins:done()
		end,