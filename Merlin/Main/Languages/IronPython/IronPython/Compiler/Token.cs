/* ****************************************************************************
 *
 * Copyright (c) Microsoft Corporation. 
 *
 * This source code is subject to terms and conditions of the Microsoft Public License. A 
 * copy of the license can be found in the License.html file at the root of this distribution. If 
 * you cannot locate the  Microsoft Public License, please send an email to 
 * dlr@microsoft.com. By using this source code in any fashion, you are agreeing to be bound 
 * by the terms of the Microsoft Public License.
 *
 * You must not remove this notice, or any other, from this software.
 *
 *
 * ***************************************************************************/

using System;
using System.Dynamic;
using Microsoft.Scripting;

namespace IronPython.Compiler {

    public struct TokenWithSpan {
        private Token _token;
        private SourceSpan _span;

        public Token Token {
            get { return _token; }
            set { _token = value; }
        }

        public SourceSpan Span {
            get { return _span; }
            set { _span = value; }
        }

        public TokenWithSpan(Token token, SourceSpan span) {
            _token = token;
            _span = span;
        }
    }

    /// <summary>
    /// Summary description for Token.
    /// </summary>
    public abstract class Token {
        private readonly TokenKind _kind;

        protected Token(TokenKind kind) {
            _kind = kind;
        }

        public TokenKind Kind {
            get { return _kind; }
        }

        public virtual object Value {
            get {
                throw new NotSupportedException(IronPython.Resources.TokenHasNoValue);
            }
        }

        public override string ToString() {
            return base.ToString() + "(" + _kind + ")";
        }

        public abstract String Image {
            get;
        }
    }

    public class ErrorToken : Token {
        private readonly String _message;

        public ErrorToken(String message)
            : base(TokenKind.Error) {
            _message = message;
        }

        public String Message {
            get { return _message; }
        }

        public override String Image {
            get { return _message; }
        }

        public override object Value {
            get { return _message; }
        }
    }

    public class ConstantValueToken : Token {
        private readonly object _value;

        public ConstantValueToken(object value)
            : base(TokenKind.Constant) {
            _value = value;
        }

        public object Constant {
            get { return this._value; }
        }

        public override object Value {
            get { return _value; }
        }

        public override String Image {
            get {
                return _value == null ? "None" : _value.ToString();
            }
        }
    }

    public class IncompleteStringToken : ConstantValueToken {
        private readonly bool _quote;
        private readonly bool _isRaw;
        private readonly bool _isUni;
        private readonly bool _isTri;

        public IncompleteStringToken(object value, bool quote, bool isRaw, bool isUnicode, bool isTripleQuoted)
            : base(value) {
            _quote = quote;
            _isRaw = isRaw;
            _isUni = isUnicode;
            _isTri = isTripleQuoted;
        }

        /// <summary>
        /// True if the quotation is written using ', false if written using "
        /// </summary>
        public bool IsSingleTickQuote {
            get { return _quote; }
        }

        /// <summary>
        /// True if the string is a raw-string (preceeded w/ r character)
        /// </summary>
        public bool IsRaw {
            get { return _isRaw; }
        }

        /// <summary>
        /// True if the string is Unicode string (preceeded w/ a u character)
        /// </summary>
        public bool IsUnicode {
            get { return _isUni; }
        }

        /// <summary>
        /// True if the string is triple quoted (''' or """)
        /// </summary>
        public bool IsTripleQuoted {
            get { return _isTri; }
        }
    }

    public sealed class CommentToken : Token {
        private readonly string _comment;

        public CommentToken(string comment)
            : base(TokenKind.Comment) {
            _comment = comment;
        }

        public string Comment {
            get { return _comment; }
        }

        public override string Image {
            get { return _comment; }
        }

        public override object Value {
            get { return _comment; }
        }
    }

    public class NameToken : Token {
        private readonly SymbolId _name;

        public NameToken(SymbolId name)
            : base(TokenKind.Name) {
            _name = name;
        }

        public SymbolId Name {
            get { return this._name; }
        }

        public override object Value {
            get { return _name; }
        }

        public override String Image {
            get {
                return SymbolTable.IdToString(_name);
            }
        }
    }

    public class OperatorToken : Token {
        private readonly int _precedence;
        private readonly string _image;

        public OperatorToken(TokenKind kind, string image, int precedence)
            : base(kind) {
            _image = image;
            _precedence = precedence;
        }

        public int Precedence {
            get { return _precedence; }
        }

        public override object Value {
            get { return _image; }
        }

        public override String Image {
            get { return _image; }
        }
    }

    public class SymbolToken : Token {
        private readonly string _image;

        public SymbolToken(TokenKind kind, String image)
            : base(kind) {
            _image = image;
        }

        public String Symbol {
            get { return _image; }
        }

        public override object Value {
            get { return _image; }
        }

        public override String Image {
            get { return _image; }
        }
    }
}
