//
//  SupabaseManager.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//
//

import Foundation
import Supabase

struct CloudSubscription: Codable {
    let name: String
    let price: Double
    let category: String
    let billing_cycle: String
    let start_date: String
    let end_date: String
    let auto_renew: Bool
    let will_renew: Bool
    let icon: String
    let is_archived: Bool
    let cloud_id: String
    let notes: String
    let icon_color_hex: String
    let user_key: String
}
final class SupabaseManager {
    
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: Secrets.supabaseURL)!,
        supabaseKey: Secrets.supabaseKey
    )

    private init() {}
    
    func uploadSubscription(_ subscription: Subscription) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let cloudSub = CloudSubscription(
            name: subscription.name,
            price: subscription.price,
            category: subscription.category.rawValue,
            billing_cycle: subscription.billingCycle.rawValue,
            start_date: formatter.string(from: subscription.startDate),
            end_date: formatter.string(from: subscription.endDate),
            auto_renew: subscription.autoRenew,
            will_renew: subscription.willRenew,
            icon: subscription.icon,
            is_archived: subscription.isArchived,
            cloud_id: subscription.cloudId,
            notes: subscription.notes,
            icon_color_hex: subscription.iconColorHex ,
            user_key: LocalUser.id
        )
        
        do {
            try await client
                .from("subscriptions")
                .insert(cloudSub)
                .execute()
            
            print("✅ Uploaded to Supabase")
        } catch {
            print("❌ Supabase upload error:", error.localizedDescription)
        }
    }
  
    func updateSubscription(_ subscription: Subscription) async {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let cloudSub = CloudSubscription(
            name: subscription.name,
            price: subscription.price,
            category: subscription.category.rawValue,
            billing_cycle: subscription.billingCycle.rawValue,
            start_date: formatter.string(from: subscription.startDate),
            end_date: formatter.string(from: subscription.endDate),
            auto_renew: subscription.autoRenew,
            will_renew: subscription.willRenew,
            icon: subscription.icon,
            is_archived: subscription.isArchived,
            cloud_id: subscription.cloudId,
            notes: subscription.notes,
            icon_color_hex: subscription.iconColorHex,
            user_key: LocalUser.id

        )

        do {
            try await client
                .from("subscriptions")
                .update(cloudSub)
                .eq("cloud_id", value: subscription.cloudId)
                .execute()

            print("✅ Updated in Supabase")

        } catch {
            print("❌ Update error:", error.localizedDescription)
        }
    }
    func deleteSubscription(_ subscription: Subscription) async {
        do {
            try await client
                .from("subscriptions")
                .delete()
                .eq("cloud_id", value: subscription.cloudId)
                .eq("user_key", value: LocalUser.id)
                .execute()
            
            print("✅ Deleted from Supabase")
        } catch {
            print("❌ Supabase delete error:", error.localizedDescription)
            
            
            
            
            
        }
    }
    func fetchSubscriptions() async -> [CloudSubscription] {
        do {
            let response: [CloudSubscription] = try await client
                .from("subscriptions")
                .select()
                .eq("user_key", value: LocalUser.id)
                .execute()
                .value
            
            print("✅ Fetched user subscriptions:", response.count)
            return response
            
        } catch {
            print("❌ Fetch error:", error.localizedDescription)
            return []
        }
    }
    func deleteSubscriptionByCloudId(_ cloudId: String) async {
        do {
            try await client
                .from("subscriptions")
                .delete()
                .eq("cloud_id", value: cloudId)
                .eq("user_key", value: LocalUser.id)
                .execute()

            print("✅ Deleted from Supabase")
        } catch {
            print("❌ Supabase delete error:", error.localizedDescription)
        }
    }
}
