//
//  MockStore.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 4/7/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class MockStore {

    static var shop = ATCShop(name: "Brazilian Steak House",
                              imageURLString: "http://1myjgijqjayl6z9b3f23e581.wpengine.netdna-cdn.com/wp-content/uploads/2017/03/JRP_6849-Edit-web.jpg",
                              streetAddress: "777 Steiner Street, San Francisco, CA, 94115")

    static var products = [
        Product(title: "Forbidden Salad",
                price: "11.00",
                images: ["https://hispanickitchen.com/wp-content/uploads/2016/07/Grilled-Chicken-Salad-feature.jpg",
                         "https://www.ourpaleolife.com//wp-content/uploads/2017/06/Taco-Salad-02.jpg",
                         "https://nutritiouslife.com/wp-content/uploads/2010/05/shutterstock_274855409-copy.jpg",
                         "https://2.bp.blogspot.com/-QlUzdZUW0N4/T7Q-8aXuG9I/AAAAAAAAOjE/zSAOKHTvwtQ/s800/Strawberry%2Band%2BBalsamic%2BGrilled%2BChicken%2BSalad%2B500%2B0545.jpg"],
                colors: [],
                sizes: [],
                id: "2",
                imageURLString: "https://hispanickitchen.com/wp-content/uploads/2016/07/Grilled-Chicken-Salad-feature.jpg",
                productDescription: "Aioli. Arugula, spinach gorgonzola, cheese, carrots, quinoa, beets." ),
        Product(title: "The Dirty Deed",
                price: "8.50",
                images: ["https://www.saveur.com/sites/saveur.com/files/styles/1000_1x_/public/import/2014/recipe_bel-air-club-sandwich_750x750.jpg?itok=wb1m7KRV"],
                colors: [],
                sizes: [],
                id: "3",
                imageURLString: "https://www.saveur.com/sites/saveur.com/files/styles/1000_1x_/public/import/2014/recipe_bel-air-club-sandwich_750x750.jpg?itok=wb1m7KRV",
                productDescription: "Signature fries with Cheddar cheese, grilled onions, bacon and aioli." ),
        Product(title: "Big Burg",
                price: "14.00",
                images: ["https://www.seriouseats.com/recipes/images/2015/07/20150728-homemade-whopper-food-lab-35.jpg"],
                colors: [],
                sizes: [],
                id: "1",
                imageURLString: "https://www.seriouseats.com/recipes/images/2015/07/20150728-homemade-whopper-food-lab-35.jpg",
                productDescription: "Anchor steam beer battered wild cod fillets with friends. Served with tartar" ),
        Product(title: "The Bandit Sandwich",
                price: "8.50",
                images: ["https://food.fnr.sndimg.com/content/dam/images/food/fullset/2011/7/28/6/FNM-090111_WN-Dinners-042_s4x3.jpg.rend.hgtvcom.616.462.suffix/1382450919080.jpeg"],
                colors: [],
                sizes: [],
                id: "4",
                imageURLString: "https://food.fnr.sndimg.com/content/dam/images/food/fullset/2011/7/28/6/FNM-090111_WN-Dinners-042_s4x3.jpg.rend.hgtvcom.616.462.suffix/1382450919080.jpeg",
                productDescription: "Medium egg, butchers cut bacon, muenster cheese and avocado." ),
        Product(title: "Deviant Sandwich",
                price: "14.00",
                images: ["https://food.fnr.sndimg.com/content/dam/images/food/fullset/2009/4/14/2/FNM060109WN023_s4x3.jpg.rend.hgtvcom.616.462.suffix/1382538949211.jpeg"],
                colors: [],
                sizes: [],
                id: "5",
                imageURLString: "https://food.fnr.sndimg.com/content/dam/images/food/fullset/2009/4/14/2/FNM060109WN023_s4x3.jpg.rend.hgtvcom.616.462.suffix/1382538949211.jpeg",
                productDescription: "Scrambled eggs, tillamook Cheddar, and chives. Served on a griddled brioche bun, organic free eggs and signature made aioli."),
        Product(title: "Red Flag",
                price: "14.00",
                images: ["https://www.seriouseats.com/recipes/images/2015/07/20150728-homemade-whopper-food-lab-35.jpg"],
                colors: [],
                sizes: [],
                id: "1",
                imageURLString: "https://www.seriouseats.com/recipes/images/2015/07/20150728-homemade-whopper-food-lab-35.jpg",
                productDescription: "Anchor steam beer battered wild cod fillets with friends. Served with tartar" ),
        Product(title: "Petty Cash Sandwich",
                price: "16.50",
                images: ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTnrdbiXRF9M9nybRbtQcibaAabmpKf3jc3DU0H_kdhUU3pl50"],
                colors: [],
                sizes: [],
                id: "1",
                imageURLString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTnrdbiXRF9M9nybRbtQcibaAabmpKf3jc3DU0H_kdhUU3pl50",
                productDescription: "Medium egg, house made chicken sausage patty, muenster cheese and spinach. Served on a griddled brioche bun." ),
        Product(title: "The Fancy Sandwich",
                price: "18.50",
                images: ["https://static.olocdn.net/menu/applebees/626fb16a97bff07eb58ac193a46fb71e.jpg"],
                colors: [],
                sizes: [],
                id: "1",
                imageURLString: "https://static.olocdn.net/menu/applebees/626fb16a97bff07eb58ac193a46fb71e.jpg",
                productDescription: "Scrambled eggs, gruyere cheese, chivers, spinach, cremini mushrooms and grilled tomatoes." )
    ]

    static var categories = [
        Category(title: "Breakfast",
                 id: "8",
                 imageURLString: "https://www.bobevans.com/-/media/bobevans_com/images/our-restaurants/2017winter/big_egg_bfast_core_winterfy17.jpg?h=333&la=en&w=500&hash=0CADDF6BC5033B2EB4521129EF2201803FFA414E"),
        Category(title: "Ramen",
                 id: "7",
                 imageURLString: "https://www.seriouseats.com/images/2014/04/20140422-sun-ramen-brands-taste-test-17.jpg"),
        Category(title: "Sandwiches",
                 id: "9",
                 imageURLString: "https://www.eggs.ca/assets/RecipePhotos/_resampled/FillWyIxMjgwIiwiNjIwIl0/triple-sandwich-032.jpg"),
        Category(title: "Mediterranean",
                 id: "1",
                 imageURLString: "https://food.fnr.sndimg.com/content/dam/images/food/fullset/2009/8/13/0/FNM100109WE059_s4x3.jpg.rend.hgtvcom.966.725.suffix/1382539115451.jpeg"),
        Category(title: "Japanese",
                 id: "2",
                 imageURLString: "https://www.rd.com/wp-content/uploads/2017/08/Attention-Sushi-Lovers-There-Are-Rules-About-Eating-Japanese-Food-That-You-Must-Follow_644962144-760x506.jpg"),
        Category(title: "Sushi",
                 id: "3",
                 imageURLString: "https://halfoff.adspayusa.com/wp-content/uploads/2018/03/sushi_and_sashimi_for_two.0.jpg"),
        Category(title: "New Mexican",
                 id: "4",
                 imageURLString: "http://gaysantafe.com/wp-content/uploads/2014/07/IMG_2182.jpg"),
        Category(title: "Bar Food",
                 id: "5",
                 imageURLString: "https://assets3.thrillist.com/v1/image/1645737/size/tmg-article_default_mobile.jpg"),
        Category(title: "Italian",
                 id: "6",
                 imageURLString: "https://cdn.websites.hibu.com/533c448531fc412eb9cff9ae03178687/dms3rep/multi/mobile/small-3.jpg"),
        Category(title: "Burgers",
                 id: "17",
                 imageURLString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWQT1w9rcptMi31e9Ev7HdQ3bj0AJ1t1KrZDLh0_vQNuHkpUHS")
    ]

    static var orders = [
        ATCOrder(id: "1", shoppingCart: MockStore.shoppingCart(), customer: nil, address: nil, status: "In transit", createdAt: Date()),
        ATCOrder(id: "2", shoppingCart: MockStore.shoppingCart(), customer: nil, address: nil, status: "In transit", createdAt: Date()),
        ATCOrder(id: "1sda", shoppingCart: MockStore.shoppingCart(), customer: nil, address: nil, status: "In transit", createdAt: Date()),
        ATCOrder(id: "134", shoppingCart: MockStore.shoppingCart(), customer: nil, address: nil, status: "In transit", createdAt: Date()),
    ]

    static func shoppingCart() -> ATCShoppingCart {
        let products = self.products.shuffled()
        let cart = ATCShoppingCart()
        cart.addProduct(product: products[0], quantity: 1)
        cart.addProduct(product: products[2], quantity: 1)
        cart.addProduct(product: products[3], quantity: 1)
        cart.addProduct(product: products[1], quantity: 1)
        return cart
    }
}
