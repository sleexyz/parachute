import SwiftUI

public extension Color {
    static var parachuteBgDark: Color {
        Color(red: 35/255, green: 31/255, blue: 32/255)
    }

    static var parachuteOrange: Color {
        Color("parachuteOrange", bundle: Bundle.module)
    }
    
    static var parachuteOrangeLight: Color {
        Color("parachuteOrangeLight", bundle: Bundle.module)
    }

    static var parachuteLabel: Color {
        Color(UIColor.label)
    }

    static var background: Color {
        Color("Background", bundle: Bundle.module)
    }

    static var darkBlueBg: Color {
        Color("DarkBlueBg", bundle: Bundle.module)
    }
    
    static var secondaryFill: Color {
        Color(red: 124/255, green: 124/255, blue: 124/255)
    }

    static var parachuteBgLight: Color {
        Color(red: 253/255, green: 233/255, blue: 210/255)
    }
}

