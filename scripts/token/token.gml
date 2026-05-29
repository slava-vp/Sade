function token(_id, _val) constructor{
	id = _id;
	val = _val;
}

enum tokenID{
	Keyword			,
	Function		,
	Value			,
	Variable		,
	
	Unar			,	// для !var, -var, var++, var--, ++var, --var
	Binary			,	// для +=, *=, -=, /=, ^=
	Operator		,	// для ==, <=, >=, !=, >>, <<
	
	Rbracket_L		,	// (
	Rbracket_R		,	// )
	Bracket_L		,	// {
	Bracket_R		,	// }
	Sbracket_L		,	// [
	Sbracket_R		,	// ]
	Semicolon		,	// ;
	Colon			,	// :
	Dot				,	// .
	Comma			,	// ,
	Double_Quotes	,	// "
	Quotes			,	// '
	Minus			,	// -
	Plus			,	// +
	More			,	// >
	Less			,	// <
	Power			,	// ^
	Mult			,	// *
	Percent			,	// %
	Equal			,	// =
	Slash			,	// /
	Slash_Back		,	// \
	Question		,	// ?
	Exclamation		,	// !
	Dog				,	// @
	Ampersand		,	// &
	Sharp			,	// #
	Dollar			,	// $
	Underscore		,	// _
	Or				,	// |
}