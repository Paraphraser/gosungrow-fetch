//
//  sungrowToCSV main.swift
//

import Foundation

enum SQLiteTypeAffinity: String {

	case none = ""
	case blob = "blob"
	case text = "text"
	case numeric = "numeric"
	case integer = "integer"
	case real = "real"
	case null = "null"

	init(_ value: String?) {

		// handle a nil argument
		guard let value = value else { self = .null; return }

		// remove any surrounding whitespace
		var s = value.trimmingCharacters(in: .whitespaces)

		// sense a null string
		guard s.count > 0 else { self = .null; return }

		// does it have a leading dot (eg ".1" instead of "0.1")?
		if s.count > 1 && s.hasPrefix(".") {

			// yes! prepend a zero
			s.insert("0", at: s.startIndex)

		}

		// can the candidate be converted to a number?
		if let number = Double(s) {

			// embedded here to avoid dependence on math methods
			func isInteger(_ d : Double) -> Bool {

				// is the value within the bounds of an Integer?
				if d >= Double(Int.min) && d <= Double(Int.max) {

					// yes! test and return
					return ((floor(d) == d) && (ceil(d) == d))

				}

				// otherwise, we can't treat it as an integer even if
				// it is a whole number
				return false

			}

			// yes! can the number be represented as an integer?
			if isInteger(number) {

				// yes! that's its type then
				self = .integer

			} else {

				// it's a number but not an integer
				self = .real

			}

		} else {

			// otherwise we treat it as text
			self = .text

		}

	}


	init(_ value: NSNull) {

		self = .null

	}

	/**
		Returns true if the affinity is one of the number forms of
		integer, numeric or real. False otherwise.
																	  */
	var isNumber : Bool {

		return
			(self == .integer) ||
			(self == .numeric) ||
			(self == .real)

	}

	/**
		The keyword form is simply the raw value converted to upper
		case. The lower-case form of the raw value is how SQLite's
		typeof() function provides information (ie meaning that an
		SQLTypeAffinity enum could be initialised from that) while
		the upper-case form is the gold standard for what appears in
		SQL commands generally, as in:

		````
		CREATE TABLE fred (jack TEXT, bill INTEGER NOT NULL);
		SELECT * FROM fred WHERE jack IS NULL;
		````
																	  */
	var keywordForm : String {

		get {
			return self.rawValue.uppercased()
		}

	}

}

extension SQLiteTypeAffinity: CustomStringConvertible {

	var description: String { return self.keywordForm }

}


// iterate while standard input has something to provide
while let line = readLine() {

	// crack the line into fields
	let fields = line.components(separatedBy: "┃")

	// don't print a separator for the first field
	var separator = false

	// do we have more than one field?
	if fields.count > 1 {

		// yes! iterate the fields
		for field in fields {

			// trim surrounding whitespace
			let trimmedField = field.trimmingCharacters(in: CharacterSet.whitespaces)

			// are we left with a string of any length?
			if trimmedField.count > 0 {

				// second or subsequent field on this line?
				if separator {

					// yes! we need a comma separator
					print(",", terminator:"")

				}

				// does the field look like a numeric?
				if SQLiteTypeAffinity(trimmedField).isNumber {

					// yes! emit it raw
					print(trimmedField, terminator:"")

				} else {

					// no! emit it quoted
					print("\"\(trimmedField)\"", terminator:"")

				}

				// any more fields need comma separation
				separator = true;

			}

		}

	}

	// separator will be true if line has at least one field
	if separator {

		// if so, terminate the line
		print("");

	}

}
