# Prepare
delay = (next) -> setTimeout(next,500)

# Export
module.exports =
	events:
		generateAfter: (opts,next) ->
			# Prepare
			docpad = @docpad

			# Test
			require('bal-util').spawn 'cake test', {output:true}, (err) ->
				if err
					message = 'TESTS FAILED'
					docpad.log('warn', message)
				else
					message = 'Tests passed'
					docpad.log('info', message)
				delay -> docpad.notify(message)
				return next()
