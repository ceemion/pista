//
//  ContactDetailsView.swift
//  hoplon
//
//  Created by Fiyinfoluwa Adebayo on 06/12/2019.
//  Copyright © 2019 Kompilab Limited. All rights reserved.
//

import SwiftUI

struct PersonDetailsView: View {

    var person: Person

    @State var openNew: Bool = false
    @State var lbActionSheet: Bool = false

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 40) {
                Button(action: { PistaFunctions().phoneCallAction(self.person.phone_number) }) {
                    Image(systemName: "phone")
                        .imageScale(.small)
                        .accessibility(label: Text("Call"))
                }
                Button(action: { PistaFunctions().openUrl("mailto:\(self.person.email)") }) {
                    Image(systemName: "envelope")
                        .imageScale(.small)
                        .accessibility(label: Text("Email"))
                }
                Image("whatsapp.icon.2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .onTapGesture {
                        PistaFunctions().openUrl("https://api.whatsapp.com/send?phone=234\(self.person.phone_number)")
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.horizontal, 20)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .center) {
                    HStack(alignment: .top, spacing: 10) {
                        SummaryView(
                            title: "total lent",
                            amount: person.total_lent,
                            color: "success")

                        SummaryView(
                            title: "total borrowed",
                            amount: person.total_borrowed,
                            color: "danger")
                    }

                    VStack(alignment: .center, spacing: 10) {
                        if person.data.isEmpty {
                            VStack(spacing: 10) {
                                Text("No transactions here yet.")
                                Text("Lent or Borrowed? Tap the plus icon up top to add a new entry.")
                            }
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding()
                        } else {
                            ForEach(person.data) { lb in
                                LBRowView(
                                    lb: lb,
                                    type: lb.status == "completed" ? "gray" : (lb.lb_type == "lent" ? "success" : "danger"),
                                    lbActionSheet: self.$lbActionSheet
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(10)
                .background(Color("sceneBg"))
            }
        }
        .navigationBarTitle(Text("\(person.first_name) \(person.last_name)"), displayMode: .inline)
        .navigationBarItems(trailing: NewEntryButton(openNew: $openNew))
        .sheet(isPresented: $openNew) {
            NewLendBorrow()
                .environmentObject(LendAndBorrowViewModel(person: self.person))
        }
    }
}

struct NewEntryButton: View {
    @Binding var openNew: Bool

    var body: some View {
        Button(action: { self.openNew.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.small)
                .accessibility(label: Text("New LendBorrow"))
                .padding()
        }
    }
}

struct LBRowView: View {
    var lb: LendBorrow
    var type: String

    @Binding var lbActionSheet: Bool

    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Options"), buttons: [
            .default(Text("Mark As Completed"), action: {
                print("tap of M A Completed")
            }),
            .destructive(Text("Delete"), action: {
                print("tap of lb Delete")
            }),
            .cancel()
        ])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\u{20A6} \(String(lb.amount))")
                    .foregroundColor(Color(type))
                    .font(Font.custom(Constants.Font.title, size: CGFloat(Constants.TextSizes.title)))
                    .strikethrough(lb.status == "completed", color: Color(type))
                Spacer()
                Button(action: { self.lbActionSheet.toggle() }) {
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .accessibility(label: Text("Info"))
                }
                .accentColor(Color(type))
                .actionSheet(isPresented: $lbActionSheet) { () -> ActionSheet in
                    self.actionSheet
                }
            }

            Group {
                Text("Date Due: \(lb.date_due.isEmpty ? "Not Stated" : formatDate(lb.date_due))")
                Text(lb.notes)
            }
            .foregroundColor(Color("text"))
            .font(Font.custom(Constants.Font.main, size: CGFloat(Constants.TextSizes.body)))

            Text(formatDateTime(lb.updated_at))
                .foregroundColor(Color("text").opacity(0.5))
                .font(Font.custom(Constants.Font.mainItalic, size: CGFloat(Constants.TextSizes.body)))

            if lb.status == "completed" {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "checkmark.seal")
                        .imageScale(.small)
                    Text("Settled Up")
                        .font(Font.custom(Constants.Font.main, size: 14))
                }
                .foregroundColor(Color("gray"))
            }
        }
        .padding()
        .background(Color(type).opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - DATE HELPERS: format dates
private func formatDateTime(_ date: String) -> String {
    let formatter = DateFormatter()

    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX") // https://developer.apple.com/library/archive/qa/qa1480/_index.html
    let dateObject = formatter.date(from: date)

    // set format to parse month in words
    formatter.dateFormat = "d MMMM yyyy, HH:mm"

    return formatter.string(from: dateObject!)
}

private func formatDate(_ date: String) -> String {
    let formatter = DateFormatter()

    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX") // https://developer.apple.com/library/archive/qa/qa1480/_index.html
    let dateObject = formatter.date(from: date)

    // set format to parse month in words
    formatter.dateFormat = "d MMMM yyyy"

    return formatter.string(from: dateObject!)
}

// MARK: - Preview
struct PersonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(
            person: Person.init(
                id: 0,
                user_id: 0,
                first_name: "",
                last_name: "",
                email: "",
                phone_number: "",
                total_lent: 0,
                total_borrowed: 0,
                data: [])
        )
    }
}
