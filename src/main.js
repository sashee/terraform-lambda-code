module.exports.handler = async (event, context, callback) => {
	const response = {
		statusCode: 200,
		body: "Hello world!",
	};
	callback(null, response);
};

