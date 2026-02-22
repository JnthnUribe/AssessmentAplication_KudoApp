import React from 'react';
import './InformationCard.css';
import GeneralInfo from './generalinfo/GeneralInfo';

const InformationCard = ({ isBlank }) => {
    return (
        <aside className="information-card">
            {!isBlank && <GeneralInfo />}
        </aside>
    );
};

export default InformationCard;
