const config = {
    antidote: [
        {
            host: 'localhost',
            port: 8087
        },
        {
            host: 'localhost',
            port: 8088
        },
        {
            host: 'localhost',
            port: 8089
        }
    ],
    partitionCmd: './net_part.sh'
};

module.exports = config;

