import ballerina/http;
import ballerina/time;
import ballerinax/prometheus as _;

type User record {
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
};

type NewUser record {
    string name;
    time:Date birthDate;
    string mobileNumber;
};

type UpdatedUser record {
    string name;
    time:Date birthDate;
    string mobileNumber;
};

type Post record {
    readonly int id;
    string description;
    string tags;
    string category;
};

type NewPost record {
    string description;
    string tags;
    string category;
};

table<User> key(id) users = table [
    {id: 1, name: "Joe", birthDate: {year: 1990, month: 2, day: 3}, mobileNumber: "0778115350"},
    {id: 2, name: "Amal", birthDate: {year: 1998, month: 12, day: 13}, mobileNumber: "0776115350"}
];

table<Post> key(id) posts = table [
    {id: 1, description: "Music makes life fun", tags: "music,singing,dancing", category: "arts"},
    {id: 2, description: "I love this movie!", tags: "movies,actors", category: "entertainment"}
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

service /social\-media on new http:Listener(9091) {
    // Resource function to retrieve all users
    resource function get users() returns User[]|error {
        return users.toArray();
    }

    // Resource function to retrieve a specific users
    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {
                body: {message: string `id: ${id}`, details: string `user/${id}`, timeStamp: utcNow()}
            };
            return userNotFound;
        }
        return user;
    }

    //  Create New User
    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.length() + 1, name: newUser.name, birthDate: newUser.birthDate, mobileNumber: newUser.mobileNumber});
        return http:CREATED;
    }

    // Update a user by ID
    // resource function put users/[int id](UpdatedUser updatedUser) returns http:Created|UserNotFound|error {
    //     User? user = users[id];
    //     if user == null {
    //         UserNotFound userNotFound = {
    //         body: {message: string `User not found with ID: ${id}`, details: string `users/${id}`, timeStamp: time:utcNow()}
    //         };
    //         return userNotFound;
    //     }
    //     user.name = updatedUser.name;
    //     user.birthDate = updatedUser.birthDate;
    //     user.mobileNumber = updatedUser.mobileNumber;
    //     return http:CREATED;
    // }

    // Delete a user by ID
    //
    // + id - The ID of the user to be deleted
    // + return - The success message or error message
    resource function delete users/[int id]() returns http:NoContent|UserNotFound|error {
        User? user = users.remove(id);
        if user == null {
            UserNotFound userNotFound = {
            body: {message: string `User not found with ID: ${id}`, details: string `users/${id}`, timeStamp: time:utcNow()}
        };
            return userNotFound;
        }
        return http:NO_CONTENT;
    }

    //  Get posts for a give user
    // 
    //  + id - The user ID for which posts are retrieved
    //  + return - A list of posts or error message
    resource function get users/[int id]/posts() returns Post[]|UserNotFound|error {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {
                body: {message: string `id: ${id}`, details: string `user/${id}`, timeStamp: utcNow()}
            };
            return userNotFound;
        }
        return posts.toArray();
    }

    //  Create New post
    resource function post users/[int id]/posts(NewPost newPost) returns http:Created|error {
        posts.add({id: posts.length() + 1, description: newPost.description, tags: newPost.tags, category: newPost.category});
        return http:CREATED;
    }

}

function utcNow() returns time:Utc {
    return [0, 0];
}

