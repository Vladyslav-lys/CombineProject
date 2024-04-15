//
//  TestUIVM.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 03.11.2022.
//

import Services

final class TestUIVM: BaseVM {
    @Published private(set) var tests: [Test]?
    
    func getTests() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let test1 = Test(title: "Film 1",
                             imageUrl: "https://images.app.goo.gl/Xix6p8LjNPDhBMHw9",
                             startTime: "19:00",
                             endTime: "21:00",
                             duration: "2 hours")
            let test2 = Test(title: "Film 2",
                             imageUrl: "https://images.app.goo.gl/Xix6p8LjNPDhBMHw9",
                             startTime: "18:30",
                             endTime: "22:00",
                             duration: "3 hours 30 minutes")
            self.tests = [test1, test2]
            self.isLoading = false
        }
    }
}
