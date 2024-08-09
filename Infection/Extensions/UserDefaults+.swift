import Foundation

extension UserDefaults {
    var wasTutorialShown: Bool {
        get { UserDefaults.standard.bool(forKey: "wasTutorialShown") }
        set { UserDefaults.standard.setValue(newValue, forKey: "wasTutorialShown") }
    }
}
