import React from 'react';
import './InformationCard.css';
import GeneralInfo from './generalinfo/GeneralInfo';

const InformationCard = () => {
    return (
        <aside className="information-card">
            <GeneralInfo />
        </aside>
    );
};

export default InformationCard;
