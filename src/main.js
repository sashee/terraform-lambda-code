module.exports.handler = async (event, context, callback) => {
	const what = "world";
	const response = `Hello ${what}!`;
	callback(null, response);
};

