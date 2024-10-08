import Foundation

extension UserDefaults {
    var localName: String? {
        get { UserDefaults.standard.string(forKey: "localName") }
        set { UserDefaults.standard.setValue(newValue, forKey: "localName") }
    }

    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isLoggedIn") }
        set { UserDefaults.standard.setValue(newValue, forKey: "isLoggedIn") }
    }

    var wasTutorialShown: Bool {
        get { UserDefaults.standard.bool(forKey: "wasTutorialShown") }
        set { UserDefaults.standard.setValue(newValue, forKey: "wasTutorialShown") }
    }
}
