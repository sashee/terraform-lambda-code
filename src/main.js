module.exports.handler = async (event, context) => {
	const what = "world";
	const response = `Hello ${what}!`;
	return response;
};

